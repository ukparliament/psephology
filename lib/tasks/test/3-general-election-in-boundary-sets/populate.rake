require 'csv'

task :general_elections_in_boundary_sets => [
  :update_parliament_periods,
  :create_2024_general_election,
  :populate_general_election_in_boundary_sets
]

# ## A task to update Parliaments.
task :update_parliament_periods => :environment do
  puts "updating parliament periods"
  
  # For each Parliament period ...
  CSV.foreach( 'db/data/parliament_periods.csv' ) do |row|
    
    # ... we store the values from the spreadsheet ...
    parliament_number = row[0].strip if row[0]
    parliament_summoned_on = row[2].strip if row[2]
    parliament_state_opening_on = row[3].strip if row[3]
    parliament_dissolved_on = row[4].strip if row[4]
    parliament_wikidata_id = row[5].strip if row[5]
    parliament_london_gazette = row[10].strip if row[10]
    
    # We attempt to find the Parliament period.
    parliament_period = ParliamentPeriod.find_by_number( parliament_number )
    
    # Unless we find the Parliament period ...
    unless parliament_period
      
      # ... we create the Parliament period.
      parliament_period = ParliamentPeriod.new
      parliament_period.number = parliament_number
      parliament_period.summoned_on = parliament_summoned_on
      parliament_period.state_opening_on = parliament_state_opening_on
      parliament_period.dissolved_on = parliament_dissolved_on
      parliament_period.wikidata_id = parliament_wikidata_id
      parliament_period.london_gazette = parliament_london_gazette
      parliament_period.save!
      
    # Otherwise, if we do find the Parliament period.
    else
      parliament_period.summoned_on = parliament_summoned_on
      parliament_period.state_opening_on = parliament_state_opening_on
      parliament_period.dissolved_on = parliament_dissolved_on
      parliament_period.wikidata_id = parliament_wikidata_id
      parliament_period.london_gazette = parliament_london_gazette
      parliament_period.save!
    end
  end
end

# ## A task to create the 2024 general election.
task :create_2024_general_election => :environment do
  puts "creating the 2024 general election"
  
  # For each general election ...
  CSV.foreach( 'db/data/general-elections.csv' ) do |row|
    
    # ... we store the values from the spreadsheet ...
    general_election_polling_on = row[0].strip if row[0]
    general_election_is_notional = row[1].strip if row[1]
    general_election_commons_library_briefing_url = row[2].strip if row[2]
    
    # We attempt to find the general election.
    general_election = GeneralElection
      .all
      .where( "polling_on = ?", general_election_polling_on )
      .where( "is_notional = ?", general_election_is_notional )
      .first
      
    # Unless we find the general_election ...
    unless general_election
      
      # ... we find the Parliament period ...
      parliament_period = get_parliament_period( general_election_polling_on )
      
      # ... and create the general election.
      general_election = GeneralElection.new
      general_election.polling_on = general_election_polling_on
      general_election.is_notional = general_election_is_notional
      general_election.commons_library_briefing_url = general_election_commons_library_briefing_url
      general_election.parliament_period = parliament_period
      general_election.save!
    end
  end
end

# ## A task to populate general elections in boundary sets.
task :populate_general_election_in_boundary_sets => :environment do
  puts "populating general elections in boundary sets"
  
  # For each general election in a boundary set ...
  CSV.foreach( 'db/data/general_election_in_boundary_sets.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    general_election_polling_on = row[0]
    country_name = row[1]
    boundary_set_id = row[2]
    ordinality = row[3]
    
    # We find the non-notional general election.
    general_election = GeneralElection.find_by_sql(
      "
        SELECT *
        FROM general_elections
        WHERE polling_on = '#{general_election_polling_on}'
        AND is_notional IS FALSE
      "
    ).first
    
    # We find the boundary set.
    boundary_set = BoundarySet.find( boundary_set_id )
    
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