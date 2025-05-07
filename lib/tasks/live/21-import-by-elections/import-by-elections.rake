require 'csv'

task :import_by_elections => [
  :import_by_election_elections,
  :import_by_election_candidacies,
  :apply_result_positions_to_by_elections,
  :apply_winning_candidacy_to_by_elections,
  :import_political_party_registrations,
  :generate_parliamentary_parties,
  :assign_non_party_flags_to_result_summaries,
  :associate_result_summaries_with_political_parties,
  :infill_missing_result_summary_text
  
  
]

# ## A task to import by-election elections.
task :import_by_election_elections => :environment do
  puts "importing by-election elections"
  
  # Import by-elections for Parliament 59.
  import_elections( 59 )
end

# ## A task to import by-election candidacies.
task :import_by_election_candidacies => :environment do
  puts "importing by-election candidacies"
  
  # Import by-election candidacies for Parliament 59.
  import_election_candidacies( 59 )
end

# ## A task to apply result positions to by-elections.
task :apply_result_positions_to_by_elections => :environment do
  puts "applying result positions to by-elections"
  
  # We get all the by-elections.
  by_elections = Election.all.where( 'general_election_id IS NULL' )
  
  # For each by-election ...
  by_elections.each do |by_election|
    
    # ... we set the result position to zero.
    result_position = 0
    
    # For each candidacy result in the by-election ...
    by_election.results.each do |candidacy|
    
      # ... we increment the result position ...
      result_position += 1
      
      # ... and set the result position on the candidacy.
      candidacy.result_position = result_position
      candidacy.save!
    end
  end
end

# ## A task to apply winning candidacy to by-elections.
task :apply_winning_candidacy_to_by_elections => :environment do
  puts "applying winning candidacy to by-elections"
  
  # We find all candidacies in a by-election with a result position of one.
  candidacies = Candidacy.find_by_sql(
    "
      SELECT c.*
      FROM candidacies c, elections e
      WHERE c.result_position = 1
      AND c.election_id = e.id
      AND e.general_election_id IS NULL
    "
  )
  
  # For each candidacy in a by-election with a result position of one ...
  candidacies.each do |candidacy|
  
    # ... we set the is winning candidacy flag to true.
    candidacy.is_winning_candidacy = true
    candidacy.save!
  end
end

# ## A task to infill missing result summary text.
task :infill_missing_result_summary_text => :environment do
  puts "infilling missing result summary text"
  
  # We find all results summaries with no summary text.
  result_summaries = ResultSummary.all.where( 'summary IS NULL' )
  
  # For each result summary with no summary text ...
  result_summaries.each do |result_summary|
  
    # ... we create a string to hold the full summary text.
    summary = ''
  
    # We get the word count of the short summary.
    word_count_short_summary = result_summary.short_summary.split( ' ' ).size
    
    # If the word count is 2 ...
    if word_count_short_summary == 2
    
      # ... we know this is a hold.
      # We get the name of the party holding the seat.
      party_name = result_summary.from_political_party.name
      
      # We construct the full summary text.
      summary += party_name
      summary += ' hold'
      
      
    # Otherwise, if the word count is 4 ...
    elsif word_count_short_summary == 4
    
      # ... we know this is a gain.
      # If the result summary is to an independent ...
      if result_summary.is_to_independent
      
        # ... we add Independent to the summary text.
        summary += 'Independent'
        
      # Otherwise if the result summary is not to an independent ...
      else
        
        # ... we add the to party name to the summary text.
        summary += result_summary.to_political_party.name
      end
      
      # ... we add the gain text to the summary text.
      summary += ' gain from '
      
      # If the result summary is from an independent ...
      if result_summary.is_from_independent
      
        # ... we add Independent to the summary text.
        summary += 'Independent'
        
      # Otherwise if the result summary is not from an independent ...
      else
        
        # ... we add the from party name to the summary text.
        summary += result_summary.from_political_party.name
      end
    
    # Otherwise ...
    else
    
      # ... we flag an unexpected word count.
      puts "unexpected word count in result summary short summary of #{word_count_short_summary}"
    end
    
    # We save the result summary with its full summary text.
    puts summary
    result_summary.summary = summary
    result_summary.save!
  end
end



# A method to import elections for a Parliament.
def import_elections( parliament_number )

  # We find the Parliament the by-election took place in.
  parliament_period = ParliamentPeriod.find_by_number( parliament_number )

  # We set the path to the constituencies file.
  constituencies_file = "db/data/results-by-parliament/#{parliament_number}/by-elections/constituencies.csv"

  # For each row in the sheet ...
  CSV.foreach( constituencies_file ).with_index do |row, index|
    next if index == 0 # Skip the first row
    
    # We store the variables we'll need to find the constituency group for the by-election.
    constituency_area_geographic_code = row[2]
    country_name = row[7]
    
    # If the Parliament period has dissolved ...
    if parliament_period.dissolved_on
    
      # ... we find the constituency group the election is for in the dissolved Parliament.
      constituency_group = ConstituencyGroup.find_by_sql(
        "
          SELECT cg.*
          FROM constituency_groups cg, constituency_areas ca, boundary_sets bs, countries c
          WHERE cg.constituency_area_id = ca.id
          AND ca.geographic_code = '#{constituency_area_geographic_code}'
          AND ca.boundary_set_id = bs.id
          AND bs.start_on < '#{parliament_period.summoned_on}'
          AND (
            bs.end_on >= '#{parliament_period.dissolved_on}'
          )
          AND bs.country_id = c.id
          AND c.name = '#{country_name}'
        "
      ).first
    
    # Otherwise, if the Parliament period has not dissolved ...
    else
    
      # ... we find the constituency group the election is for in the current Parliament.
      constituency_group = ConstituencyGroup.find_by_sql(
        "
          SELECT cg.*
          FROM constituency_groups cg, constituency_areas ca, boundary_sets bs, countries c
          WHERE cg.constituency_area_id = ca.id
          AND ca.geographic_code = '#{constituency_area_geographic_code}'
          AND ca.boundary_set_id = bs.id
          AND bs.start_on < '#{parliament_period.summoned_on}'
          AND (
            bs.end_on IS NULL
          )
          AND bs.country_id = c.id
          AND c.name = '#{country_name}'
        "
      ).first
    end
    
    # We store the variables we need to find the electorate for the by-election.
    electorate_population_count = row[16]
    
    # We attempt to find the electorate for the by-election.
    electorate = Electorate.find_by_sql(
      "
        SELECT * 
        FROM electorates
        WHERE population_count = #{electorate_population_count}
        AND constituency_group_id = #{constituency_group.id}
      "
    ).first
    
    # Unless we find the electorate for the by-election ...
    unless electorate
      
      # ... we create the electorate.
      electorate = Electorate.new
      electorate.population_count = electorate_population_count
      electorate.constituency_group = constituency_group
      electorate.save!
    end
    
    # We store the variable we need to find the result summary.
    election_result_short_summary = row[13]
    
    # We attempt to find the result summary.
    result_summary = ResultSummary.find_by_short_summary( election_result_short_summary )
    
    # Unless we find the result summary ...
    unless result_summary
    
      # ... we create the result summary.
      result_summary = ResultSummary.new
      result_summary.short_summary = election_result_short_summary
      result_summary.save!
    end
    
    # We store the variables we need to populate the by-election.
    election_writ_issued_on = row[1].to_date
    election_polling_on = row[0].to_date
    election_valid_vote_count = row[17]
    election_invalid_vote_count = row[18]
    election_majority = row[19]
    
    # We attempt to find the by-election.
    election = Election.find_by_sql(
      "
        SELECT *
        FROM elections
        WHERE general_election_id IS NULL
        AND polling_on = '#{election_polling_on}'
        AND constituency_group_id = #{constituency_group.id}
      "
    ).first
    
    # Unless we find the by-election ...
    unless election
    
      # ... we create the by-election.
      election = Election.new
    end
    
    # We populate or update the by-election data attributes.
    election.writ_issued_on = election_writ_issued_on
    election.polling_on = election_polling_on
    election.valid_vote_count = election_valid_vote_count
    election.invalid_vote_count = election_invalid_vote_count
    election.majority = election_majority
    
    # We populate or update the by-election relationships.
    election.constituency_group = constituency_group
    election.electorate = electorate
    election.parliament_period = parliament_period
    election.result_summary = result_summary
    election.save!
  end
end

# A method to import election candidacies for a Parliament.
def import_election_candidacies( parliament_number )

  # We set the path to the candidacies file.
  constituencies_file = "db/data/results-by-parliament/#{parliament_number}/by-elections/candidacies.csv"

  # For each row in the sheet ...
  CSV.foreach( constituencies_file ).with_index do |row, index|
    next if index == 0 # Skip the first row
    
    # We store the variables we need to find the election.
    polling_date = row[0].to_date
    constituency_area_geographic_code = row[1]
    
    # We find the election.
    election = Election.find_by_sql(
      "
      SELECT e.*
      FROM elections e, constituency_groups cg, constituency_areas ca
      WHERE e.polling_on = '#{polling_date}'
      AND e.constituency_group_id = cg.id
      AND cg.constituency_area_id = ca.id
      AND ca.geographic_code = '#{constituency_area_geographic_code}'
      "
    ).first
    
    # We store the variables we need to find the gender.
    candidacy_gender = row[15]
    
    # We find the gender.
    gender = Gender.find_by_gender( candidacy_gender )
    
    # We store the variables we need to find or populate the member.
    member_mnis_id = row[18]
    candidacy_given_name = row[13]
    candidacy_family_name = row[14]
    
    # If the candidacy has a MNIS ID ...
    if member_mnis_id
    
      # ... we attempt to find the member with that ID.
      member = Member.find_by_mnis_id( member_mnis_id )
      
      # Unless we find the member ...
      unless member
      
        # ... we create the member.
        member = Member.new
      end
      
      # We set or reset the attributes on the member.
      member.given_name = candidacy_given_name
      member.family_name = candidacy_family_name
      member.mnis_id = member_mnis_id
      member.save!
    end
    
    # We store the variables we need to find or populate the candidacy.
    candidate_democracy_club_id = row[22]
    if row[16] == 'Yes'
      candidate_is_sitting_mp = true
    elsif row[16] == 'No'
      candidate_is_sitting_mp = false
    end
    if row[17] == 'Yes'
      candidate_is_former_mp = true
    elsif row[17] == 'No'
      candidate_is_former_mp = false
    end
    if row[8] == 'Independent'
      candidate_is_standing_as_independent = true
    else
      candidate_is_standing_as_independent = false
    end
    candidacy_vote_count = row[19]
    candidacy_vote_share = row[20]
    candidacy_vote_change = row[21]
    
    # We attempt to find the candidacy.
    candidacy = Candidacy.find_by_sql(
      "
        SELECT *
        FROM candidacies
        WHERE election_id = #{election.id}
        AND democracy_club_person_identifier = #{candidate_democracy_club_id}
      "
    ).first
    
    # Unless we find the candidacy ...
    unless candidacy
      
      # ... we create the candidacy.
      candidacy = Candidacy.new
    end
    
    # We set or reset the attributes on the candidacy.
    candidacy.candidate_given_name = candidacy_given_name
    candidacy.candidate_family_name = candidacy_family_name
    candidacy.candidate_is_sitting_mp = candidate_is_sitting_mp
    candidacy.candidate_is_former_mp = candidate_is_former_mp
    candidacy.is_standing_as_independent = candidate_is_standing_as_independent
    candidacy.vote_count = candidacy_vote_count
    candidacy.vote_share = candidacy_vote_share
    candidacy.vote_change = candidacy_vote_change
    candidacy.democracy_club_person_identifier = candidate_democracy_club_id
    candidacy.election = election
    candidacy.candidate_gender = gender
    candidacy.member = member if member
    candidacy.save!
    
    # We store the variable we need to find or create the party.
    party_name = row[8]
    party_abbreviation = row[9]
    party_mnis_id = row[11]
    
    # Unless the 'party name' is 'Independent'.
    unless party_name == 'Independent'
    
      # If the party name is 'Labour and Co-operative' ...
      if party_name == 'Labour and Co-operative'
      
        # ... we find the Labour party.
        labour_party = PoliticalParty.find_by_name( 'Labour' )
        
        # We attempt to find a certification of the candidacy by the Labour party.
        labour_certification = Certification.find_by_sql(
          "
            SELECT *
            FROM certifications
            WHERE political_party_id = #{labour_party.id}
            AND adjunct_to_certification_id IS NULL
            AND candidacy_id = #{candidacy.id}
          "
        ).first
        
        # Unless we find a certification of the candidacy by the Labour party ...
        unless labour_certification
          
          # ... we create it.
          labour_certification = Certification.new
          labour_certification.candidacy = candidacy
          labour_certification.political_party = labour_party
          labour_certification.save!
        end
      
        # ... we find the Co-operative party.
        cooperative_party = PoliticalParty.find_by_name( 'Co-operative Party' )
        
        # We attempt to find a certification of the candidacy by the Co-operative party as an adjunct to the Labour party certification.
        cooperative_certification = Certification.find_by_sql(
          "
            SELECT *
            FROM certifications
            WHERE political_party_id = #{cooperative_party.id}
            AND adjunct_to_certification_id = #{labour_certification.id}
            AND candidacy_id = #{candidacy.id}
          "
        ).first
        
        # Unless we find a certification of the candidacy by the Co-operative party as an adjunct to the Labour party certification ...
        unless cooperative_certification
        
          puts labour_certification.id
          
          # ... we create it.
          cooperative_certification = Certification.new
          cooperative_certification.candidacy = candidacy
          cooperative_certification.political_party = cooperative_party
          cooperative_certification.adjunct_to_certification_id = labour_certification.id
          cooperative_certification.save!
        end
        
      # Otherwise, if the party name is not 'Labour and Co-operative' ...
      else
      
        # ... we attempt to find the political party.
        political_party = PoliticalParty.find_by_mnis_id( party_mnis_id )
        
        # If we find the political party ...
        if political_party
          
          # ... if the name of the political party does not match the name in the spreadsheet ...
          if political_party.name != party_name
          
            # ... we put an alert.
            puts "Mistmatch between party name in database (#{political_party.name}) and party name in spreadsheet (#{party_name})."
          end
        end
        
        # Unless we find the political party ...
        unless political_party
        
          # ... we create the political party with all its attributes because we don't want to overwrite them.
          political_party = PoliticalParty.new
          political_party.name = party_name
          political_party.abbreviation = party_abbreviation
          political_party.mnis_id = party_mnis_id
          political_party.save!
          
          puts political_party.inspect
        end
        
        # We attempt to find a certification of the candidacy by the political party.
        certification = Certification.find_by_sql(
          "
            SELECT *
            FROM certifications
            WHERE candidacy_id = #{candidacy.id}
            AND political_party_id = #{political_party.id}
          "
        ).first
        
        # Unless we find a certification of the candidacy by the political party ...
        unless certification
        
          # ... we create it.
          certification = Certification.new
          certification.candidacy = candidacy
          certification.political_party = political_party
          certification.save!
        end
      end
    end
  end
end