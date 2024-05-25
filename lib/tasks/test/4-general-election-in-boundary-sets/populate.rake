# ## A task to populate general elections in boundary sets.

task :populate_general_election_in_boundary_sets => :environment do
  puts "populating general elections in boundary sets"
  
  # For each general election in a boundary set ...
  CSV.foreach( 'db/data/general_election_in_boundary_sets.csv' ) do |row|
    
    # 2010-05-06,England,2010-04-13,2024-05-30,1
    
    # ... we store the values from the spreadsheet.
    general_election_polling_on = row[0]
    country_name = row[1]
    boundary_set_start_on = row[2]
    boundary_set_end_on = row[3]
    ordinality = row[4]
    
    # We find the non-notional general election.
    general_election = GeneralElection.find_by_sql(
      "
        SELECT *
        FROM general_elections
        WHERE polling_on = '#{general_election_polling_on}'
        AND is_notional IS FALSE
      "
    ).first
    
    # We find the country.
    country = Country.find_by_name( country_name )
    
    # We find the boundary set.
    boundary_set = BoundarySet.find_by_sql(
      "
        SELECT *
        FROM boundary_sets
        WHERE country_id = #{country.id}
        AND start_on = '#{boundary_set_start_on}'
      "
    ).first
    
    # We attempt to find a general election in the boundary set.
    general_election_in_boundary_set = GeneralElectionInBoundarySet.find_by_sql(
      "
        SELECT *
        FROM general_election_in_boundary_sets
        WHERE general_election_id = #{general_election.id}
        AND boundary_set_id = #{boundary_set.id}
      "
    ).first
    
    # Unless we find the general election in the boundary set.
    unless general_election_in_boundary_set
      
      # ... we create the general election in the boundary set.
      general_election_in_boundary_set = GeneralElectionInBoundarySet.new
      general_election_in_boundary_set.general_election = general_election
      general_election_in_boundary_set.boundary_set = boundary_set
      general_election_in_boundary_set.ordinality = ordinality
      general_election_in_boundary_set.save!
    end
  end
end