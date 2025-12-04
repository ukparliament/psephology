task :load_2005_notional_general_election => [
  :report_start_time,
  :create_2005_notional_general_election,
  :create_2005_notional_general_election_constituency_elections,
  :import_2005_notional_general_election_candidacies,
  :populate_result_position_on_notional_general_election_candidacies,
  :populate_majority_on_notional_general_election_constituency_elections,
  :report_end_time
]

# ## A task to create the 2005 notional general election.
task :create_2005_notional_general_election => :environment do
  puts "creating the 2005 notional general election"
  
  # We attempt to find the notional general election.
  general_election = GeneralElection
    .where( 'is_notional IS TRUE' )
    .where( "polling_on = ?", '2005-05-05' )
    .first
  
  # Unless we find the 2005 notional general election ...
  unless general_election
  
    # ... we create the 2005 notional general election.
    general_election = GeneralElection.new
    general_election.polling_on = '2005-05-05'.to_date
    general_election.is_notional = true
    general_election.parliament_period_id = 54
    general_election.general_election_publication_state_id = 4
    general_election.save!
  end
end

# ## A task to create the 2005 notional general election constituency elections.
task :create_2005_notional_general_election_constituency_elections => :environment do
  puts "creating the 2005 notional general election constituency elections"
  
  # We find all the constituencies in operation at the time of the next general election.
  constituency_groups = ConstituencyGroup.find_by_sql(
    "
      SELECT cg.*
      FROM constituency_groups cg, constituency_areas ca, boundary_sets bs
      WHERE cg.constituency_area_id = ca.id
      AND ca.boundary_set_id = bs.id
      AND bs.start_on < '2010-05-06'
      AND bs.end_on > '2010-05-06'
    "
  )
  
  # We find the notional general election.
  general_election = GeneralElection
    .where( 'is_notional IS TRUE' )
    .where( "polling_on = ?", '2005-05-05' )
    .first
    
  # For each constituency in operation at the time of the notional general election ...
  constituency_groups.each do |constituency_group|
  
    # ... we attempt to find a notional election for this notional general election in this constituency.
    election = Election
      .where( 'is_notional IS TRUE' )
      .where( "general_election_id = ?", general_election.id )
      .where( "constituency_group_id = ?", constituency_group.id )
      .first
      
    # Unless we find a notional election for this notional general election in this constituency ...
    unless election
  
      # ... we create a new notional election.
      election = Election.new
      election.writ_issued_on = '2005-04-11'.to_date
      election.polling_on = '2005-05-05'.to_date
      election.is_notional = true
      election.constituency_group = constituency_group
      election.general_election = general_election
      election.parliament_period = general_election.parliament_period
      election.save!
    end
  end
end

# ## A task to create the 2005 notional general election constituency elections.
task :import_2005_notional_general_election_candidacies => :environment do
  puts "importing the 2005 notional general election candidacies"
  
  # We find the notional general election.
  general_election = GeneralElection
    .where( 'is_notional IS TRUE' )
    .where( "polling_on = ?", '2005-05-05' )
    .first
  
  # We set the location of the results CSV.
  results_file = 'db/data/results-by-parliament/54/notional-general-election/results.csv'
  
  # For each candidacy in the results file ...
  CSV.foreach( results_file).with_index do |row, index|
  
    # ... we skip the first row.
    next if index == 0
    
    # We store the geographic code of the constituency.
    constituency_area_geographic_code = row[0].strip
    
    # We find the election this candidacy was in.
    election = Election.find_by_sql(
      "
        SELECT e.*
        FROM elections e, constituency_groups cg, constituency_areas ca
        WHERE e.general_election_id = #{general_election.id}
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.geographic_code = '#{constituency_area_geographic_code}'
        
      "
    ).first
    
    # We store the values we need to populate the election and the electorate.
    valid_vote_count = row[6].strip.to_i
    electorate_population_count = row[7].strip.to_i

    # If the valid votes count is different to that stored on the election ...
    if election.valid_vote_count != valid_vote_count

      # ... we set the valid vote count on the election.
      election.valid_vote_count = valid_vote_count
      election.save!
    end
    
    # If the election has an electorate ...
    if election.electorate_id

      # If the electorate population count is different to that stored on the electorate ...
      if electorate_population_count != election.electorate.population_count
  
        # ... we reset the electorate population count.
        election.electorate.population_count = electorate_population_count
        election.electorate.save!
      end
  
    # Otherwise, if the election does not have an electorate ...
    else
  
      # ... we create an electorate ...
      electorate = Electorate.new
      electorate.population_count = electorate_population_count
      electorate.constituency_group_id = election.constituency_group_id
      electorate.save!
  
      # ... and attach the election to its electorate.
      election.electorate = electorate
      election.save!
    end
    
    # We store the information we need to find the 'political party'.
    political_party_mnis_id = row[2].strip

    # We store the data we need to populate the candidacy.
    vote_count = row[5].strip
    vote_share = row[8].strip
    
    # If the political party MNIS ID is a notional political party aggregate ...
    if political_party_mnis_id == 'NA'

      # TODO: deal with aggregate parties.
      #puts "we've found an aggregate"
      # is_notional_political_party_aggregate

      # ... we attempt to find a candidacy in this election for a notional political party aggregate.
      candidacy = Candidacy.find_by_sql(
        "
          SELECT cand.*
          FROM candidacies cand
          WHERE cand.election_id = #{election.id}
          AND cand.is_notional_political_party_aggregate IS TRUE
        "
      ).first
    
      # Unless we find a candidacy in this election for a notional political party aggregate ...
      unless candidacy

        # ... we create the candidacy.
        candidacy = Candidacy.new
        candidacy.is_notional_political_party_aggregate = true
        candidacy.is_notional = true
        candidacy.vote_count = vote_count
        candidacy.vote_share = vote_share
        candidacy.election = election
        candidacy.save!
      end
      
    # Otherwise, if the 'political party' is independent ...
    elsif political_party_mnis_id.to_i == 8

      # ... we attempt to find a candidacy in this election for an independent.
      candidacy = Candidacy.find_by_sql(
        "
          SELECT cand.*
          FROM candidacies cand
          WHERE cand.election_id = #{election.id}
          AND cand.is_standing_as_independent IS TRUE
        "
      ).first
    
      # Unless we find a candidacy in this election for an independent ...
      unless candidacy

        # ... we create the candidacy.
        candidacy = Candidacy.new
        candidacy.is_standing_as_independent = true
        candidacy.is_notional = true
        candidacy.vote_count = vote_count
        candidacy.vote_share = vote_share
        candidacy.election = election
        candidacy.save!
      end
  
    # Otherwise, if the 'political party' is commons speaker ...
    elsif political_party_mnis_id.to_i == 47

      # ... we attempt to find a candidacy in this election for the commons speaker.
      candidacy = Candidacy.find_by_sql(
        "
          SELECT cand.*
          FROM candidacies cand
          WHERE cand.election_id = #{election.id}
          AND cand.is_standing_as_commons_speaker IS TRUE
        "
      ).first
    
      # Unless we find a candidacy in this election for the commons speaker ...
      unless candidacy

        # ... we create the candidacy.
        candidacy = Candidacy.new
        candidacy.is_standing_as_commons_speaker = true
        candidacy.is_notional = true
        candidacy.vote_count = vote_count
        candidacy.vote_share = vote_share
        candidacy.election = election
        candidacy.save!
      end

    # Otherwise, if the political party MNIS ID is a real political party ....
    else

      # ... we attempt to find a candidacy in this election for this party.
      candidacy = Candidacy.find_by_sql(
        "
          SELECT cand.*
          FROM candidacies cand, certifications cert, political_parties pp
          WHERE cand.election_id = #{election.id}
          AND cand.id = cert.candidacy_id
          AND cert.adjunct_to_certification_id IS NULL
          AND cert.political_party_id = pp.id
          AND pp.mnis_id = #{political_party_mnis_id}
        "
      ).first
      
      # Unless we find a candidacy in this election for this party ...
      unless candidacy
  
        # ... we create the candidacy.
        candidacy = Candidacy.new
        candidacy.is_notional = true
        candidacy.vote_count = vote_count
        candidacy.vote_share = vote_share
        candidacy.election = election
        candidacy.save!
        
        # We find the political party ...
        political_party = PoliticalParty.find_by_mnis_id( political_party_mnis_id.to_i )
    
         # ... and create a certification of the candidacy by the political party.
        certification = Certification.new
        certification.candidacy = candidacy
        certification.political_party = political_party
        certification.save!
      end
    end
  end
end

# ## A task to populate result positions on candidacies in the 2005 notional general election.
task :populate_result_position_on_notional_general_election_candidacies => :environment do
  puts "populating result positions on candidacies in the 2005 notional general election"
    
  # We find the notional general election.
  general_election = GeneralElection
    .where( 'is_notional IS TRUE' )
    .where( "polling_on = ?", '2005-05-05' )
    .first
    
  # For each election in the notional general election ...
  general_election.elections.each do |election|
  
    # We set the result position to start at zero.
    result_position = 0
    
    # For each candidacy in the election ...
    election.results.each do |candidacy|
      
      # ... we increment the result position ...
      result_position += 1
      
      # ... and store it on the candidacy.
      candidacy.result_position = result_position
      
      # If the result position is 1 ...
      if result_position == 1
      
        # ... we flag the candidacy as the winning candidacy.
        candidacy.is_winning_candidacy = true
      end
      
      # We save the candidacy.
      candidacy.save!
    end
  end
end

# ## A task to populate majority on 2005 notional general election constituency elections.
task :populate_majority_on_notional_general_election_constituency_elections => :environment do
  puts "populating majority on 2005 notional general election constituency elections"
  

    
  # We find the notional general election.
  general_election = GeneralElection
    .where( 'is_notional IS TRUE' )
    .where( "polling_on = ?", '2005-05-05' )
    .first
    
  # For each election in the notional general election ...
  general_election.elections.each do |election|
  
    # ... we calculate the majority by subtracting the vote count of the second candidacy from the vote count of the first.
    majority = election.results[0].vote_count - election.results[1].vote_count
    
    # We set the majority on the election.
    election.majority = majority
    election.save!
  end
end