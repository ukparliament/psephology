require 'csv'

# We set the Parliament number.
PARLIAMENT_NUMBER_2024 = 59

# We set the polling date.
POLLING_ON_2024 = '2024-07-04'

task :update_general_election_2024 => [
  :report_start_time,
  :update_2024_constituency_results,
  :update_2024_candidacy_results,
  :update_2024_result_positions,
  :report_end_time
]

# ## A task to update 2024 election constituency results.
task :update_2024_constituency_results => :environment do
  puts "updating 2024 election constituency results"
  
  # It populates:
  # * electorate.population_count
  # * election.valid_vote_count
  # * election.invalid_vote_count
  # * election.majority
  # * election.election.declaration_at
  
  
  
  
  
  
  
  # We find the general election this election forms part of.
  general_election = GeneralElection.find_by_polling_on( POLLING_ON_2024 )
  
  # For each row in the results sheet ...
  CSV.foreach( "db/data/results-by-parliament/#{PARLIAMENT_NUMBER_2024}/general-election/constituencies.csv" ) do |row|
    
    # We store the new data we want to capture in the database.
    election_declaration_at = row[7].strip if row[7]
    election_result_type = row[11].strip if row[11]
    election_valid_vote_count = row[15].strip if row[15]
    election_invalid_vote_count = row[16].strip if row[16]
    election_majority = row[17].strip if row[17]
    electorate_count = row[14].strip if row[14]
    
    
    
    # ========= REMOVE THIS =========
    # We know that some values won't be present in the initial CSVs.
    # We hardcode known missing values, for later removal.
    #election_declaration_at = election_declaration_at || Time.now
    election_valid_vote_count = election_valid_vote_count || 4472
    election_invalid_vote_count = election_invalid_vote_count || 4472
    election_majority = election_majority || 4472
    electorate_count = electorate_count || 4472
    # ========= REMOVE THIS =========
    
    
    
    # We store the data we need to find the candidacy, quoted for SQL.
    constituency_area_geographic_code = ActiveRecord::Base.connection.quote( row[0] )
    
    # We find the winning candidacy.
    candidacy = Candidacy.find_by_sql(
      "
        SELECT c.*
        FROM candidacies c, elections e, constituency_groups cg, constituency_areas ca
        WHERE c.result_position = 1
        AND c.election_id = e.id
        AND e.general_election_id = #{general_election.id}
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.geographic_code = #{constituency_area_geographic_code}
        ORDER BY c.vote_count DESC
      "
    ).first
    
    # We annotate the election results.
    # We use a method defined in the setup script.
    annotate_election_results( candidacy, election_result_type, election_valid_vote_count, election_invalid_vote_count, election_majority, electorate_count, election_declaration_at )
  end
end