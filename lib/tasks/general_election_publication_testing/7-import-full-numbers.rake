task :import_full_vote_numbers => [
  :report_start_time,
  :import_constituency_numbers,
  :import_candidacy_numbers,
  :import_candidacy_numbers,
  :generate_general_election_cumulative_vote_counts,
  :populate_result_positions_on_candidacies,
  :report_end_time
]

# A task to import constituency numbers.
task :import_constituency_numbers => :environment do

  # We find the general election.
  general_election = GeneralElection.find( GENERAL_ELECTION_ID )

  # We reset the publication state of the general election to post-election votes.
  general_election.general_election_publication_state_id = 4
  general_election.save!
  
  # For each row in the constituency spreadsheet ...
  CSV.foreach( "db/data/results-by-parliament/#{NEW_PARLIAMENT_NUMBER}/publication-state-tests/results/constituencies.csv"  ).with_index do |row, index|
    
    # ... we skip the first row.
    next if index == 0
  
    # We store the geographic code of the constituency area.
    geographic_code = row[0]
    
    # We find the constituency group belonging to the constituency area with this ONS identifier belonging to an open boundary set.
    constituency_group = ConstituencyGroup.find_by_sql([
      "
        SELECT cg.*
        FROM constituency_groups cg, constituency_areas ca, boundary_sets bs
        WHERE cg.constituency_area_id = ca.id
        AND ca.geographic_code = ?
        AND ca.boundary_set_id = bs.id
        AND bs.end_on IS NULL
      ", geographic_code
    ]).first
    
    # We attempt to find an election for this constituency group in this general election.
    election = Election
      .where( "general_election_id = ?", general_election.id )
      .where( "constituency_group_id = ?", constituency_group.id )
      .first
      
    # We store the numbers we need to populate the election.
    valid_vote_count = row[15].strip if row[15]
    invalid_vote_count = row[16].strip if row[16]
    majority = row[17].strip if row[17]
    
    # We populate the election.
    election.valid_vote_count = valid_vote_count
    election.invalid_vote_count = invalid_vote_count
    election.majority = majority
    election.save!
    
    # We store the electorate population.
    electorate_population = row[14].strip if row[14]
    
    # If the election has an electorate ...
    if election.electorate
    
      # ... we update the electorate with the population
      election.electorate.population_count = electorate_population
      election.electorate.save!
      
    # Otherwise, if the election does not have an electorate ...
    else
    
      # We create a new electorate ...
      electorate = Electorate.new
      electorate.population_count = electorate_population
      electorate.constituency_group = election.constituency_group
      electorate.save!
      
      # ... and associate the election with the electorate.
      election.electorate = electorate
      election.save!
    end
  end
end

# A task to import candidacy numbers.
task :import_candidacy_numbers => :environment do
  
  # For each row in the candidacies spreadsheet ...
  CSV.foreach( "db/data/results-by-parliament/#{NEW_PARLIAMENT_NUMBER}/publication-state-tests/results/candidacies.csv"  ).with_index do |row, index|
    
    # ... we skip the first row.
    next if index == 0
    
    # We store the variables we need to find the candidate.
    geographic_code = row[0].strip if row[0]
    democracy_club_identifier = row[21].strip if row[21]
    
    # We attempt to find the candidacy.
    # We include the general election and the constituency area geographic code to ensure we match the correct record.
    candidacy = Candidacy.find_by_sql([
      "
        SELECT cand.*
        FROM candidacies cand, elections e, constituency_groups cg, constituency_areas ca
        WHERE cand.election_id = e.id
        AND e.general_election_id = ?
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.geographic_code = ?
        AND cand.democracy_club_person_identifier = ?
      ", GENERAL_ELECTION_ID, geographic_code, democracy_club_identifier
    ]).first
    
    # We store the variables we need to find the Member.
    member_mnis_id = row[17].strip if row[17]
    
    # If there is a Member MNIS API ...
    if member_mnis_id
    
      # ... we attempt to find the Member.
      member = Member.find_by_mnis_id( member_mnis_id )
    
      # Unless we find the Member ...
      unless member
    
        # ... we store the variables we need to create the Member.
        family_name = row[13].strip if row[13]
        given_name = row[12].strip if row[12]
      
        # We create the Member.
        member = Member.new
        member.given_name = given_name
        member.family_name = family_name
        member.mnis_id = member_mnis_id
        member.save!
      end
    end
    
    # We store the values we need to populate the candidacy.
    vote_count = row[18].strip if row[18]
    vote_share = row[19].strip if row[19]
    vote_change = row[20].strip if row[20]
    
    # We populate the candidacy.
    candidacy.vote_count = vote_count
    candidacy.vote_share = vote_share
    candidacy.vote_change = vote_change
    candidacy.save!
  end
end

# A task to import general election cumulative vote counts.
task :generate_general_election_cumulative_vote_counts => :environment do
  
  # This task populates:
  # * general_election.valid_vote_count
  # * general_election.invalid_vote_count
  # * general_election.electorate_population_count

  # We find the general election.
  general_election = GeneralElection.find( GENERAL_ELECTION_ID )
  
  # We set the valid vote count, the invalid vote count and the electorate population count to zero.
  valid_vote_count = 0
  invalid_vote_count = 0
  electorate_population_count = 0
    
  # For each election in the general election ...
  general_election.elections.each do |election|
      
    # ... we add the valid vote count, invalid vote count and electorate population count.
    valid_vote_count += election.valid_vote_count
    invalid_vote_count += election.invalid_vote_count if election.invalid_vote_count
    electorate_population_count += election.electorate_population_count
  end
    
  # We save the cumulative counts.
  general_election.valid_vote_count = valid_vote_count
  general_election.invalid_vote_count = invalid_vote_count
  general_election.electorate_population_count = electorate_population_count
  general_election.save!
end

# A task to populate result positions.
task :populate_result_positions_on_candidacies => :environment do
  
  # This task populates:
  # * candidacy.result_position
  
  # We find the general election.
  general_election = GeneralElection.find( GENERAL_ELECTION_ID )
  
  # For each election in the general election ...
  general_election.elections.each do |election|
    
    # ... we set the result position to zero.
    result_position = 0
    
    # For each candidacy result in the election ...
    election.results.each do |result|
      
      # ... we increment the result position ...
      result_position += 1
      
      # ... and save the result position on the candidacy.
      result.result_position = result_position
      result.save!
    end
  end
end