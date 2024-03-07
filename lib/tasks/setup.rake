require 'csv'

task :setup => [
  :import_countries,
  :import_parliament_periods,
  :import_by_election_briefings_to_parliament_periods,
  :import_legislation_types,
  :import_acts,
  :import_orders,
  :import_genders,
  :import_general_elections,
  :import_election_candidacy_results,
  :import_boundary_sets_from_orders,
  :import_boundary_sets_from_acts,
  :attach_constituency_areas_to_boundary_sets,
  :import_election_constituency_results,
  #:import_new_constituencies,
  :generate_constituency_group_sets,
  #:import_constituency_area_overlaps,
  #:populate_whole_of_booleans_on_constituency_area_overlaps,
  :import_commons_library_dashboards,
  #:import_notional_results,
  #:import_2024_candidacy_results,
  #:import_2024_constituency_results,
  :populate_result_positions,
  :generate_general_election_cumulative_counts,
  :generate_parliamentary_parties,
  :assign_non_party_flags_to_result_summaries,
  :import_expanded_result_summaries,
  :associate_result_summaries_with_political_parties,
  :generate_general_election_party_performances,
  :generate_boundary_set_general_election_party_performances,
  :generate_english_region_general_election_party_performances,
  :infill_missing_boundary_set_general_election_party_performances,
  :generate_political_party_switches,
  :generate_graphviz
]



# ## A task to countries.
task :import_countries => :environment do
  puts "importing countries"
  
  # For each country ...
  CSV.foreach( 'db/data/countries.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    country_name = row[0]
    country_geographic_code = row[1]
    country_parent_country_geographic_code = row[2]
    
    # If the country has a parent country ...
    if country_parent_country_geographic_code
      
      # ... we attempt to find the parent country.
      parent_country = Country.find_by_geographic_code( country_parent_country_geographic_code )
    end
    
    # ... and create the country.
    country = Country.new
    country.name = country_name
    country.geographic_code = country_geographic_code
    country.parent_country_id = parent_country.id if parent_country
    country.save!
  end
end

# ## A task to import parliaments.
task :import_parliament_periods => :environment do
  puts "importing parliament periods"
  
  # For each Parliament period ...
  CSV.foreach( 'db/data/parliament_periods.csv' ) do |row|
    
    # ... we store the values from the spreadsheet ...
    parliament_number = row[0]
    parliament_summoned_on = row[2]
    parliament_state_opening_on = row[3]
    parliament_dissolved_on = row[4]
    parliament_wikidata_id = row[5]
    parliament_london_gazette = row[10]
    
    # ... and create the Parliament period.
    parliament_period = ParliamentPeriod.new
    parliament_period.number = parliament_number
    parliament_period.summoned_on = parliament_summoned_on
    parliament_period.state_opening_on = parliament_state_opening_on
    parliament_period.dissolved_on = parliament_dissolved_on
    parliament_period.wikidata_id = row[5]
    parliament_period.london_gazette = parliament_london_gazette
    parliament_period.save
  end
end

# ## A task to import by-election research briefings to parliaments.
task :import_by_election_briefings_to_parliament_periods => :environment do
  puts "importing by-election briefings to parliament periods"
  
  # For each by-election briefing ...
  CSV.foreach( 'db/data/by-elections-in-parliament.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    parliament_number = row[0]
    commons_library_briefing_by_election_briefing_url = row[1]
    
    # We attempt to find the parliament period.
    parliament_period = ParliamentPeriod.all.where( 'number = ?', parliament_number ).first
    
    # If we find the parliament period ...
    if parliament_period
      
      # ... we add the commons library by-election briefing url to the parliament period.
      parliament_period.commons_library_briefing_by_election_briefing_url = commons_library_briefing_by_election_briefing_url
      parliament_period.save
    end
  end
end

# ## A task to import legislation types.
task :import_legislation_types => :environment do
  puts "importing legislation types"
  
  # For each legislation type ...
  CSV.foreach( 'db/data/legislation/types.csv' ) do |row|
    
    # ... we store the values from the spreadsheet ...
    legislation_type_abbreviation = row[0]
    legislation_type_label = row[1]
    
    # ... and create the legislation type.
    legislation_type = LegislationType.new
    legislation_type.abbreviation = legislation_type_abbreviation
    legislation_type.label = legislation_type_label
    legislation_type.save
  end
end

# ## A task to import Acts of Parliament.
task :import_acts => :environment do
  puts "importing acts of parliament"
  
  # We find the legislation type.
  legislation_type = LegislationType.find_by_abbreviation( 'acts' )
  
  # For each act ...
  CSV.foreach( 'db/data/legislation/acts.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    legislation_item_title = row[0]
    legislation_item_uri = row[1]
    legislation_item_url_key = row[2]
    legislation_item_royal_assent_on = row[3]
    
    # We attempt to find the legislation item.
    legislation_item = LegislationItem.find_by_url_key( legislation_item_url_key )
    
    # Unless we find the legislation item ...
    unless legislation_item
      
      # ... we create it.
      legislation_item = LegislationItem.new
      legislation_item.title = legislation_item_title
      legislation_item.uri = legislation_item_uri
      legislation_item.url_key = legislation_item_url_key
      legislation_item.royal_assent_on = legislation_item_royal_assent_on
      legislation_item.statute_book_on = legislation_item_royal_assent_on
      legislation_item.legislation_type = legislation_type
      legislation_item.save
    end
  end
end

# ## A task to import Orders in Council.
task :import_orders => :environment do
  puts "importing orders in council"
  
  # We find the legislation type.
  legislation_type = LegislationType.find_by_abbreviation( 'orders' )
  
  # For each order ...
  CSV.foreach( 'db/data/legislation/orders.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    legislation_item_title = row[0]
    legislation_item_uri = row[1]
    legislation_item_url_key = row[2]
    legislation_item_made_on = row[3]
    legislation_enabling_act_one = row[4]
    legislation_enabling_act_two = row[5]
    
    # We attempt to find the legislation item.
    legislation_item = LegislationItem.find_by_url_key( legislation_item_url_key )
    
    # Unless we find the legislation item ...
    unless legislation_item
      
      # ... we create it.
      legislation_item = LegislationItem.new
      legislation_item.title = legislation_item_title
      legislation_item.uri = legislation_item_uri
      legislation_item.url_key = legislation_item_url_key
      legislation_item.made_on = legislation_item_made_on
      legislation_item.statute_book_on = legislation_item_made_on
      legislation_item.legislation_type = legislation_type
      legislation_item.save
    
      # If the order has an enabling Act ...
      if legislation_enabling_act_one
      
        # ... we find the enabling Act ...
        enabling_act = LegislationItem.find_by_title( legislation_enabling_act_one )
      
        # ... and create a new enabling.
        enabling = Enabling.new
        enabling.enabling_legislation_id = enabling_act.id
        enabling.enabled_legislation_id = legislation_item.id
        enabling.save
      end
    
      # If the order has two enabling Acts ...
      if legislation_enabling_act_two
      
        # ... we find the enabling Act ...
        enabling_act = LegislationItem.find_by_title( legislation_enabling_act_two )
      
        # ... and create a new enabling.
        enabling = Enabling.new
        enabling.enabling_legislation_id = enabling_act.id
        enabling.enabled_legislation_id = legislation_item.id
        enabling.save
      end
    end
  end
end

# ## A task to import genders.
task :import_genders => :environment do
  puts "importing genders"
  
  # For each gender ...
  CSV.foreach( 'db/data/genders.csv' ) do |row|
    
    # ... we store the values from the spreadsheet ...
    gender_gender = row[0]
    
    # ... and create the gender.
    gender = Gender.new
    gender.gender = gender_gender
    gender.save
  end
end

# ## A task to import general elections.
task :import_general_elections => :environment do
  puts "importing general elections"
  
  # For each general election ...
  CSV.foreach( 'db/data/general-elections.csv' ) do |row|
    
    # ... we find the Parliament period.
    parliament_period = get_parliament_period( row[0] )
    
    # We store the values from the spreadsheet ...
    general_election_polling_on = row[0]
    general_election_is_notional = row[1]
    general_election_commons_library_briefing_url = row[2]
    
    # ... and create the general election.
    general_election = GeneralElection.new
    general_election.polling_on = general_election_polling_on
    general_election.is_notional = general_election_is_notional
    general_election.commons_library_briefing_url = general_election_commons_library_briefing_url
    general_election.parliament_period = parliament_period
    general_election.save
  end
end

# ## A task to import election candidacy results.
task :import_election_candidacy_results => :environment do
  puts "importing election candidacy_results"
  
  # We import results for the 2015-05-07 general election.
  parliament_number = 56
  polling_on = '2015-05-07'
  import_election_candidacy_results( parliament_number, polling_on )
  
  # We import results for the 2017-06-08 general election.
  parliament_number = 57
  polling_on = '2017-06-08'
  import_election_candidacy_results( parliament_number, polling_on )
  
  # We import results for the 2019-12-12 general election.
  parliament_number = 58
  polling_on = '2019-12-12'
  import_election_candidacy_results( parliament_number, polling_on )
end

# ## A task to import boundary sets from orders.
task :import_boundary_sets_from_orders => :environment do
  puts "importing boundary_sets from orders"
  
  # For each order ...
  CSV.foreach( 'db/data/legislation/orders.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    legislation_item_url_key = row[2]
    legislation_boundary_set_start_date = row[6]
    legislation_boundary_set_end_date = row[7]
    legislation_country = row[8]
    
    # We find the Order in Council establishing this boundary set.
    legislation_item = LegislationItem.find_by_url_key( legislation_item_url_key )
    
    # We find the country the boundary set is for.
    country = Country.find_by_name( legislation_country )
    
    # If the start date is not supplied ...
    if legislation_boundary_set_start_date.blank?
      
      # ... we attempt to find the boundary set for the given country with a null start date.
      boundary_set = BoundarySet.where( "start_on is null" ).where( "country_id = ?", country.id ).first
    
    # Otherwise, if the start date is supplied ...
    else
        
      # ... we attempt to find the boundary set for the given country with the given start date.
      boundary_set = BoundarySet.where( "start_on = ?", legislation_boundary_set_start_date ).where( "country_id = ?", country.id ).first
    end
    
    # Unless we find the boundary set ...
    unless boundary_set
    
      # ... we create it.
      boundary_set = BoundarySet.new
      boundary_set.start_on = legislation_boundary_set_start_date
      boundary_set.end_on = legislation_boundary_set_end_date if legislation_boundary_set_end_date
      boundary_set.country = country
      boundary_set.save!
    end
    
    # We associated the boundary set with it's establishing legislation.
    boundary_set_legislation_item = BoundarySetLegislationItem.new
    boundary_set_legislation_item.boundary_set = boundary_set
    boundary_set_legislation_item.legislation_item = legislation_item
    boundary_set_legislation_item.save!
  end
end

# ## A task to import boundary sets from Acts.
task :import_boundary_sets_from_acts => :environment do
  puts "importing boundary_sets from acts"
  
  # For each Act ...
  CSV.foreach( 'db/data/legislation/acts.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    legislation_item_url_key = row[2]
    legislation_boundary_set_start_date = row[4]
    legislation_boundary_set_end_date = row[5]
    legislation_country = row[6]
    
    # If the Act establishes a boundary set with a start date ...
    if legislation_boundary_set_start_date
    
      # ... we find the Act establishing this boundary set.
      legislation_item = LegislationItem.find_by_url_key( legislation_item_url_key )
    
      # We find the country the boundary set is for.
      country = Country.find_by_name( legislation_country )
    
      # We attempt to find this boundary set.
      boundary_set = BoundarySet.where( "start_on = ?", legislation_boundary_set_start_date ).where( "country_id = ?", country.id ).first
    
      # Unless we find the boundary set ...
      unless boundary_set
    
        # ... we create the it.
        boundary_set = BoundarySet.new
        boundary_set.start_on = legislation_boundary_set_start_date
        boundary_set.end_on = legislation_boundary_set_end_date if legislation_boundary_set_end_date
        boundary_set.country = country
        boundary_set.save!
      end
      
      # We associated the boundary set with it's establishing legislation.
      boundary_set_legislation_item = BoundarySetLegislationItem.new
      boundary_set_legislation_item.boundary_set = boundary_set
      boundary_set_legislation_item.legislation_item = legislation_item
      boundary_set_legislation_item.save!
    end
  end
end

# ## A task to attach constituency areas to boundary sets.
task :attach_constituency_areas_to_boundary_sets => :environment do
  puts "attaching constituency areas to boundary sets"
  
  # We get all the constituency areas.
  constituency_areas = ConstituencyArea.all
  
  # For each constituency area ...
  constituency_areas.each do |constituency_area|
    
    # ... we get the date of an election in that area.
    election_polling_on = constituency_area.elections.first.polling_on
    
    # We find the boundary set for the country the constituency area is in on the date the election took place.
    boundary_set = get_boundary_set( constituency_area.country_id, 'old' )
      
    # We attach the constituency area to its boundary set.
    constituency_area.boundary_set = boundary_set
    constituency_area.save!
  end
end

# ## A task to import election constituency results.
task :import_election_constituency_results => :environment do
  puts "importing election constituency results"
  
  # We import results for the 2015-05-07 general election.
  parliament_number = 56
  polling_on = '2015-05-07'
  import_election_constituency_results( parliament_number, polling_on )
  
  # We import results for the 2017-06-08 general election.
  parliament_number = 57
  polling_on = '2017-06-08'
  import_election_constituency_results( parliament_number, polling_on )
  
  # We import results for the 2019-12-12 general election.
  parliament_number = 58
  polling_on = '2019-12-12'
  import_election_constituency_results( parliament_number, polling_on )
end

# ## A task to import new constituencies.
task :import_new_constituencies => :environment do
  puts "importing new constituencies"
  
  # For each new constituency ...
  CSV.foreach( 'db/data/new-constituencies.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    new_constituency_country_or_region = row[2]
    new_constituency_name = row[3]
    new_constituency_area_type = row[5]
    new_constituency_geographic_code = row[7]
    
    # We find the constituency area type.
    constituency_area_type = ConstituencyAreaType.find_by_area_type( new_constituency_area_type )
    
    # We find the country and region if in England.
    case new_constituency_country_or_region
    when 'Wales'
      country = Country.find_by_name( 'Wales' )
    when "Scotland"
      country = Country.find_by_name( 'Scotland' )
    when "Northern Ireland"
      country = Country.find_by_name( 'Northern Ireland' )
    else
      country = Country.find_by_name( 'England' )
      english_region = EnglishRegion.find_by_name( new_constituency_country_or_region )
    end
    
    # We find the boundary set.
    boundary_set = get_boundary_set( country.id, 'new' )
    
    # We create the new constituency area.
    constituency_area = ConstituencyArea.new
    constituency_area.name = new_constituency_name
    constituency_area.geographic_code = new_constituency_geographic_code
    constituency_area.constituency_area_type = constituency_area_type
    constituency_area.country = country
    constituency_area.english_region = english_region if english_region
    constituency_area.boundary_set = boundary_set
    constituency_area.save!
    
    # We create the new constituency group.
    constituency_group = ConstituencyGroup.new
    constituency_group.name = new_constituency_name
    constituency_group.constituency_area = constituency_area
    constituency_group.save!
  end
end

# ## A task to generate constituency group sets.
task :generate_constituency_group_sets => :environment do
  puts 'generating constituency group sets'
  
  # We get all the constituency groups.
  constituency_groups = ConstituencyGroup.all
  
  # For each constituency group ...
  constituency_groups.each do |constituency_group|
    
    # ... we get the boundary set.
    boundary_set = constituency_group.boundary_set
    
    # If the boundary_set has a start date ...
    if boundary_set.start_on
      
      # ... we attempt to find a constituency group set for this country with this start date.
      constituency_group_set = ConstituencyGroupSet.all.where( "start_on = ?", boundary_set.start_on ).where( "country_id = ?", boundary_set.country_id ).first
      
    # Otherwise, if the boundary set has no start date ...
    else
      
      # ... we attempt to find a constituency group set for this country with a NULL start date.
      constituency_group_set = ConstituencyGroupSet.all.where( "start_on IS NULL" ).where( "country_id = ?", boundary_set.country_id ).first
    end
    
    # Unless we find a constituency group set for this country with this start date ...
    unless constituency_group_set
    
      # ... we create a new constituency group set.
      constituency_group_set = ConstituencyGroupSet.new
      constituency_group_set.start_on = boundary_set.start_on
      constituency_group_set.end_on = boundary_set.end_on
      constituency_group_set.country = boundary_set.country
      constituency_group_set.save!
      
      # We get the legislation items establishing the boundary set.
      legislation_items = boundary_set.establishing_legislation
      
      # For each legislation item ...
      legislation_items.each do |legislation_item|
        
        # ... we create a new constituency group set legislation item.
        constituency_group_set_legislation_item = ConstituencyGroupSetLegislationItem.new
        constituency_group_set_legislation_item.constituency_group_set = constituency_group_set
        constituency_group_set_legislation_item.legislation_item = legislation_item
        constituency_group_set_legislation_item.save!
      end
    end
    
    # We attach the constituency group to its constituency group set.
    constituency_group.constituency_group_set = constituency_group_set
    constituency_group.save!
  end
end

# ## A task to import constituency area overlaps.
task :import_constituency_area_overlaps => :environment do
  puts "importing constituency area overlaps"
  
  # For each constituency area overlap ...
  CSV.foreach( 'db/data/constituency-area-overlaps.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    from_constituency_area_geographic_code = row[0]
    to_constituency_area_geographic_code = row[2]
    from_constituency_area_residential_overlap = row[4]
    to_constituency_area_residential_overlap = row[5]
    from_constituency_area_geographic_overlap = row[6]
    to_constituency_area_geographic_overlap = row[7]
    from_constituency_area_population_overlap = row[8]
    to_constituency_area_population_overlap = row[9]
    
    # If dissolution has happened ...
    if has_dissolution_happened?
    
      # ... we find the from constituency area in the boundary set with a non-NULL start date and a non-NULL end date ...
      from_constituency_area = ConstituencyArea.find_by_sql(
        "
          SELECT ca.*
          FROM constituency_areas ca, boundary_sets bs
          WHERE ca.geographic_code = '#{from_constituency_area_geographic_code}'
          AND ca.boundary_set_id = bs.id
          AND bs.start_on IS NOT NULL
          AND bs.end_on IS NOT NULL
        "
      ).first
  
      # ... and we find the to constituency area in the boundary set with a non-NULL start date and a NULL end date ...
      to_constituency_area = ConstituencyArea.find_by_sql(
        "
          SELECT ca.*
          FROM constituency_areas ca, boundary_sets bs
          WHERE ca.geographic_code = '#{to_constituency_area_geographic_code}'
          AND ca.boundary_set_id = bs.id
          AND bs.start_on IS NOT NULL
          AND bs.end_on IS NULL
        "
      ).first
      
    # Otherwise, if dissolution has not happened ...
    else
    
      # ... we find the from constituency area in the boundary set with a non-NULL start date and a NULL end date ...
      from_constituency_area = ConstituencyArea.find_by_sql(
        "
          SELECT ca.*
          FROM constituency_areas ca, boundary_sets bs
          WHERE ca.geographic_code = '#{from_constituency_area_geographic_code}'
          AND ca.boundary_set_id = bs.id
          AND bs.start_on IS NOT NULL
          AND bs.end_on IS NULL
        "
      ).first
  
      # ... and we find the to constituency area in the boundary set with a NULL start date and a NULL end date ...
      to_constituency_area = ConstituencyArea.find_by_sql(
        "
          SELECT ca.*
          FROM constituency_areas ca, boundary_sets bs
          WHERE ca.geographic_code = '#{to_constituency_area_geographic_code}'
          AND ca.boundary_set_id = bs.id
          AND bs.start_on IS NULL
          AND bs.end_on IS NULL
        "
      ).first
    end
    
    # We create a new constituency area overlap.
    constituency_area_overlap = ConstituencyAreaOverlap.new
    constituency_area_overlap.from_constituency_area_id = from_constituency_area.id
    constituency_area_overlap.to_constituency_area_id = to_constituency_area.id
    constituency_area_overlap.from_constituency_residential = from_constituency_area_residential_overlap
    constituency_area_overlap.to_constituency_residential = to_constituency_area_residential_overlap
    constituency_area_overlap.from_constituency_geographical = from_constituency_area_geographic_overlap
    constituency_area_overlap.to_constituency_geographical = to_constituency_area_geographic_overlap
    constituency_area_overlap.from_constituency_population = from_constituency_area_population_overlap
    constituency_area_overlap.to_constituency_population = to_constituency_area_population_overlap
    constituency_area_overlap.save!
  end
end

# ## A task to populate whole of booleans on constituency area overlaps.
task :populate_whole_of_booleans_on_constituency_area_overlaps => :environment do
  puts "populating whole of booleans on constituency area overlaps"
  
  # We get all the constituency area overlaps.
  constituency_area_overlaps = ConstituencyAreaOverlap.all
  
  # For each constituency area overlap ...
  constituency_area_overlaps.each do |constituency_area_overlap|
    
    # ... we get the from constituency area.
    from_constituency_area = constituency_area_overlap.from_constituency_area
    
    # If the from constituency area has one overlap with a future constituency area ...
    if from_constituency_area.overlaps_to.size == 1
      
      # ... we set the constituency area overlap formed from whole of boolean to true.
      constituency_area_overlap.formed_from_whole_of = true
      constituency_area_overlap.save!
    end
    
    # We get the to constituency area.
    to_constituency_area = constituency_area_overlap.to_constituency_area
    
    # If the to constituency area has one overlap with a past constituency area ...
    if to_constituency_area.overlaps_from.size == 1
      
      # ... we set the constituency area overlap forms whole of boolean to true.
      constituency_area_overlap.forms_whole_of = true
      constituency_area_overlap.save!
    end
  end
end

# ## A task to import commons library dashboards.
task :import_commons_library_dashboards => :environment do
  puts "importing commons library dashboards"
  
  # For each library dashboard ...
  CSV.foreach( 'db/data/commons-library-dashboards.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    dashboard_title = row[0]
    dashboard_url = row[1]
    dashboard_available_for_england = row[2]
    dashboard_available_for_wales = row[3]
    dashboard_available_for_scotland = row[4]
    dashboard_available_for_northern_ireland = row[5]
    
    # We create the library dashboard.
    commons_library_dashboard = CommonsLibraryDashboard.new
    commons_library_dashboard.title = dashboard_title
    commons_library_dashboard.url = dashboard_url
    commons_library_dashboard.save!
    
    # We associate dashboard with countries the data is applicable in.
    if dashboard_available_for_england == 'true'
      country = Country.find_by_name( 'England' )
      commons_library_dashboard_country = CommonsLibraryDashboardCountry.new
      commons_library_dashboard_country.commons_library_dashboard = commons_library_dashboard
      commons_library_dashboard_country.country = country
      commons_library_dashboard_country.save!
    end
    if dashboard_available_for_wales == 'true'
      country = Country.find_by_name( 'Wales' )
      commons_library_dashboard_country = CommonsLibraryDashboardCountry.new
      commons_library_dashboard_country.commons_library_dashboard = commons_library_dashboard
      commons_library_dashboard_country.country = country
      commons_library_dashboard_country.save!
    end
    if dashboard_available_for_scotland == 'true'
      country = Country.find_by_name( 'Scotland' )
      commons_library_dashboard_country = CommonsLibraryDashboardCountry.new
      commons_library_dashboard_country.commons_library_dashboard = commons_library_dashboard
      commons_library_dashboard_country.country = country
      commons_library_dashboard_country.save!
    end
    if dashboard_available_for_northern_ireland == 'true'
      country = Country.find_by_name( 'Northern Ireland' )
      commons_library_dashboard_country = CommonsLibraryDashboardCountry.new
      commons_library_dashboard_country.commons_library_dashboard = commons_library_dashboard
      commons_library_dashboard_country.country = country
      commons_library_dashboard_country.save!
    end
  end
end




# TODO: import notional results here.

# TODO: import 2024 results here.





# ## A task to populate result positions on candidacies.
task :populate_result_positions => :environment do
  puts "populating result positions on candidacies"
  
  # We get all the elections.
  elections = Election.all
  
  # For each election ...
  elections.each do |election|
    
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

# ## A task to generate general election cumulative counts.
task :generate_general_election_cumulative_counts => :environment do
  puts "generating general election cumulative counts"
  
  # We get all general elections.
  general_elections = GeneralElection.all
  
  # For each general election ...
  general_elections.each do |general_election|
    
    # ... we set the valid vote count, the invalid vote count and the electorate population count to zero.
    valid_vote_count = 0
    invalid_vote_count = 0
    electorate_population_count = 0
    
    # For each election in the general election ...
    general_election.elections.each do |election|
      
      # ... we add the valid vote count, invalid vote count and electorate population count.
      valid_vote_count += election.valid_vote_count
      invalid_vote_count += election.invalid_vote_count
      electorate_population_count += election.electorate_population_count
    end
    
    # We save the cumulative counts.
    general_election.valid_vote_count = valid_vote_count
    general_election.invalid_vote_count = invalid_vote_count
    general_election.electorate_population_count = electorate_population_count
    general_election.save
  end
end

# ## A task to generate parliamentary parties.
task :generate_parliamentary_parties => :environment do
  puts "generating parliamentary parties"
  
  # We get all the political parties.
  political_parties = PoliticalParty.all
  
  # For each political party ...
  political_parties.each do |political_party|
    
    # ... we get the non-notional winning candidacies.
    non_notional_winning_candidacies = political_party.non_notional_winning_candidacies
    
    # If the non-notional winning candidacies is not empty ...
    unless non_notional_winning_candidacies.empty?
      
      # ... we set the has been parliamentary party flag to true.
      political_party.has_been_parliamentary_party = true
      political_party.save!
    end
  end
end

# ## A take to assign non-party flags - Speaker and Independent - to result summaries.
task :assign_non_party_flags_to_result_summaries => :environment do
  puts "assigning non-party flags - Speaker and Independent - to result summaries"
  
  # We get all the result summaries.
  result_summaries = ResultSummary.all
  
  # For each result summary ...
  result_summaries.each do |result_summary|
    
    # ... we want to deal with Labour / Co-op as Labour, so we remove any mention of ' Coop'.
    result_summary.short_summary.gsub!( ' Coop', '' )
    
    # If the short summary is two words long ...
    if result_summary.short_summary.split( ' ' ).size == 2
      
      # ... we know this is a holding party.
      # If the first word indicates Commons Speaker ...
      if result_summary.short_summary.split( ' ' ).first == 'Spk'
        
        # ... we update the result summary to say Speaker holding.
        result_summary.is_from_commons_speaker = true
        result_summary.is_to_commons_speaker = true
        result_summary.save!
      
      # Otherwise, if the first word indicates Independent ...
      elsif result_summary.short_summary.split( ' ' ).first == 'Ind'
        
        # ... we update the result summary to say Independent holding.
        result_summary.is_from_independent = true
        result_summary.is_to_independent = true
        result_summary.save!
      end
      
    # Otherwise, if the short summary is four words long ...
    elsif result_summary.short_summary.split( ' ' ).size == 4
      
      # ... we know this is a gaining party.
      # If the first word indicates Commons Speaker ...
      if result_summary.short_summary.split( ' ' ).first == 'Spk'
        
        # ... we update the result summary to say Speaker gaining.
        result_summary.is_to_commons_speaker = true
        result_summary.save!
      
      # Otherwise, if the first word indicates Independent ...
      elsif result_summary.short_summary.split( ' ' ).first == 'Ind'
        
        # ... we update the result summary to say Independent gaining.
        result_summary.is_to_independent = true
        result_summary.save!
      end
      
      # If the last word indicates Commons Speaker ...
      if result_summary.short_summary.split( ' ' ).last == 'Spk'
        
        # ... we update the result summary to say Speaker losing.
        result_summary.is_from_commons_speaker = true
        result_summary.save!
      
      # Otherwise, if the last word indicates Independent ...
      elsif result_summary.short_summary.split( ' ' ).last == 'Ind'
        
        # ... we update the result summary to say Independent losing.
        result_summary.is_from_independent = true
        result_summary.save!
      end
    end
  end
end

# ## A task to import expanded result summaries.
task :import_expanded_result_summaries => :environment do
  puts "importing expanded result summaries"
  
  # For each result summary ...
  CSV.foreach( 'db/data/result_summaries.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    result_summary_short_summary = row[0]
    result_summary_expanded_summary = row[1]
    
    # We attempt to find the result summary.
    result_summary = ResultSummary.where( "short_summary = ?", result_summary_short_summary ).first
    
    # If we find the result summary ...
    if result_summary
    
      # ... we set the expanded summary.
      result_summary.summary = result_summary_expanded_summary
      result_summary.save!
    end
  end
end

# ## A task to associate result summaries with political parties.
task :associate_result_summaries_with_political_parties => :environment do
  puts "associating result summaries with political parties"
  
  # We get all the result summaries.
  result_summaries = ResultSummary.all
  
  # For each result summary ....
  result_summaries.each do |result_summary|
    
    # ... we want to deal with Labour / Co-op as Labour, so we remove any mention of ' Coop'.
    result_summary.short_summary.gsub!( ' Coop', '' )
    
    # If the short summary is two words long ...
    if result_summary.short_summary.split( ' ' ).size == 2
      
      # ... it must be a holding.
      # Unless the result summary is from the Commons Speaker or from an independent.
      unless result_summary.is_from_commons_speaker == true || result_summary.is_from_independent == true
        
        # We get the party abbreviation ...
        party_abbreviation = result_summary.short_summary.split( ' ' ).first
      
        # ... and attempt to find the political party.
        holding_political_party = PoliticalParty.find_by_abbreviation( party_abbreviation )
      
        # We associate the result summary with the political party.
        result_summary.from_political_party_id = holding_political_party.id
        result_summary.to_political_party_id = holding_political_party.id
      end
      
      
    # Otherwise, if the short summary is four words long ...
    elsif result_summary.short_summary.split( ' ' ).size == 4
      
      # ... it must be a gain from.
      # Unless the result summary is a gain by the Commons Speaker or by an independent.
      unless result_summary.is_to_commons_speaker == true || result_summary.is_to_independent == true
        
        # ... we get the gaining party abbreviation ...
        gaining_party_abbreviation = result_summary.short_summary.split( ' ' ).first
      
        # ... and attempt to find the political party.
        gaining_political_party = PoliticalParty.find_by_abbreviation( gaining_party_abbreviation )
      
        # We associate the result summary with the gaining political party.
        result_summary.to_political_party_id = gaining_political_party.id
      end
      
      # Unless the result summary is a loss by the Commons Speaker or by an independent ...
      unless result_summary.is_from_commons_speaker == true || result_summary.is_from_independent == true
      
        # ... we get the losing party abbreviation ...
        losing_party_abbreviation = result_summary.short_summary.split( ' ' ).last
      
        # ... and attempt to find the political party.
        losing_political_party = PoliticalParty.find_by_abbreviation( losing_party_abbreviation )
      
        # We associate the result summary with the losing political party.
        result_summary.from_political_party_id = losing_political_party.id
      end
    end
    
    # We save the result summary.
    result_summary.save!
  end
end

# ## A task to generate general election party performances.
task :generate_general_election_party_performances => :environment do
  puts "generating general election party performances"
  
  # We get all the general elections.
  general_elections = GeneralElection.all
  
  # We get all the political parties.
  political_parties = PoliticalParty.all
  
  # For each political party ...
  political_parties.each do |political_party|
    
    # ... for each general election ...
    general_elections.each do |general_election|
      
      # ... we attempt to find the general election party performance for this party.
      general_election_party_performance = GeneralElectionPartyPerformance
        .all
        .where( "general_election_id = ?", general_election.id )
        .where( "political_party_id = ?", political_party.id )
        .first
      
      # Unless we find the general election party performance for this party ...
      unless general_election_party_performance
        
        # ... we create a general election party performance with all counts set to zero.
        general_election_party_performance = GeneralElectionPartyPerformance.new
        general_election_party_performance.general_election = general_election
        general_election_party_performance.political_party = political_party
        general_election_party_performance.constituency_contested_count = 0
        general_election_party_performance.constituency_won_count = 0
        general_election_party_performance.cumulative_vote_count = 0
        general_election_party_performance.cumulative_valid_vote_count = 0
      end
      
      # For each election forming part of the general election ...
      general_election.elections.each do |election|
        
        # ... if a candidacy representing the political party is in the election ...
        if political_party.represented_in_election?( election )
          
          # ... we increment the constituency contested count.
          general_election_party_performance.constituency_contested_count += 1
          
          # We add the vote count of the party candidate to the cumulative vote count.
          general_election_party_performance.cumulative_vote_count += election.political_party_candidacy( political_party ).vote_count
          
          # We add the valid vote count in the election to the cumulative valid vote count.
          general_election_party_performance.cumulative_valid_vote_count += election.valid_vote_count
          
          # If the winning candidacy in the election represented the political party ...
          if political_party.won_election?( election )
          
            # ... we increment the constituency won count.
            general_election_party_performance.constituency_won_count += 1
          end
        end
        
        # We save the general election party performance record.
        general_election_party_performance.save!
      end
    end
  end
end

# ## A task to generate boundary set general election party performances.
task :generate_boundary_set_general_election_party_performances => :environment do
  puts "generating boundary set general election party performances"
  
  # We get all the general elections.
  general_elections = GeneralElection.all
  
  # We get all the political parties having won a parliamentary election.
  political_parties = PoliticalParty.all.where( 'has_been_parliamentary_party IS TRUE' )
  
  # We get all the boundary sets.
  boundary_sets = BoundarySet.all
  
  # For each boundary set ...
  boundary_sets.each do |boundary_set|
  
    # ... for each political party ...
    political_parties.each do |political_party|
    
      # ... for each general election ...
      general_elections.each do |general_election|
        
        # ... for each election forming part of the general election in this boundary set ...
        general_election.elections_in_boundary_set( boundary_set ).each do |election|
          
          # ... if a candidacy representing the political party is in the election ...
          if political_party.represented_in_election?( election )
            
            # ... we attempt to find the general election party performance for this party in this boundary set.
            boundary_set_general_election_party_performance = BoundarySetGeneralElectionPartyPerformance
              .all
              .where( "general_election_id = ?", general_election.id )
              .where( "political_party_id = ?", political_party.id )
              .where( "boundary_set_id = ?", boundary_set.id )
              .first
      
            # Unless we find the general election party performance for this party in this boundary set ...
            unless boundary_set_general_election_party_performance
              
              # ... we create a general election party performance for this boundary set with all counts set to zero.
              boundary_set_general_election_party_performance = BoundarySetGeneralElectionPartyPerformance.new
              boundary_set_general_election_party_performance.general_election = general_election
              boundary_set_general_election_party_performance.political_party = political_party
              boundary_set_general_election_party_performance.boundary_set = boundary_set
              boundary_set_general_election_party_performance.constituency_contested_count = 0
              boundary_set_general_election_party_performance.constituency_won_count = 0
              boundary_set_general_election_party_performance.cumulative_vote_count = 0
            end
            
            # We increment the constituency contested count ...
            boundary_set_general_election_party_performance.constituency_contested_count += 1
            
            # ... and add the vote count of the party candidate to the cumulative vote count.
            boundary_set_general_election_party_performance.cumulative_vote_count += election.political_party_candidacy( political_party ).vote_count
          
            # If the winning candidacy in the election represented the political party ...
            if political_party.won_election?( election )
          
              # ... we increment the constituency won count,
              boundary_set_general_election_party_performance.constituency_won_count += 1
            end
            
            # We save the general election party performance record.
            boundary_set_general_election_party_performance.save!
          end
        end
      end
    end
  end
end

# ## A task to generate English region general election party performances.
task :generate_english_region_general_election_party_performances => :environment do
  puts "generating english region general election party performances"
  
  # We get all the general elections.
  general_elections = GeneralElection.all
  
  # We get all the political parties.
  political_parties = PoliticalParty.all
  
  # We get all the english regions.
  english_regions = EnglishRegion.all
  
  # For each english region ...
  english_regions.each do |english_region|
  
    # ... for each political party ...
    political_parties.each do |political_party|
    
      # ... for each general election ...
      general_elections.each do |general_election|
        
        # ... for each election forming part of the general election in this english region ...
        general_election.elections_in_english_region( english_region ).each do |election|
          
          # ... if a candidacy representing the political party is in the election ...
          if political_party.represented_in_election?( election )
            
            # ... we attempt to find the general election party performance for this party in this english region.
            english_region_general_election_party_performance = EnglishRegionGeneralElectionPartyPerformance
              .all
              .where( "general_election_id = ?", general_election.id )
              .where( "political_party_id = ?", political_party.id )
              .where( "english_region_id = ?", english_region.id )
              .first
      
            # Unless we find the general election party performance for this party in this english region ...
            unless english_region_general_election_party_performance
              
              # ... we create a general election party performance for this english region with all counts set to zero.
              english_region_general_election_party_performance = EnglishRegionGeneralElectionPartyPerformance.new
              english_region_general_election_party_performance.general_election = general_election
              english_region_general_election_party_performance.political_party = political_party
              english_region_general_election_party_performance.english_region = english_region
              english_region_general_election_party_performance.constituency_contested_count = 0
              english_region_general_election_party_performance.constituency_won_count = 0
              english_region_general_election_party_performance.cumulative_vote_count = 0
            end
            
            # We increment the constituency contested count ...
            english_region_general_election_party_performance.constituency_contested_count += 1
            
            # ... and add the vote count of the party candidate to the cumulative vote count.
            english_region_general_election_party_performance.cumulative_vote_count += election.political_party_candidacy( political_party ).vote_count
          
            # If the winning candidacy in the election represented the political party ...
            if political_party.won_election?( election )
          
              # ... we increment the constituency won count,
              english_region_general_election_party_performance.constituency_won_count += 1
            end
            
            # We save the english region general election party performance record.
            english_region_general_election_party_performance.save!
          end
        end
      end
    end
  end
end

# ## A task to infill missing boundary set general election party performances.
task :infill_missing_boundary_set_general_election_party_performances => :environment do
  puts "infilling missing boundary_set_general election party performances"
  
  # We know that some political parties have stood candidates in some general elections in a boundary set but not in others.
  # This makes it difficult to render boundary set level party performance tables.
  # For any boundary set in a general election with no candidates from a given political party, where that political party has stood candidates in other general elections in that boundary set, we create a boundary set general election party performance record having no contested, won or vote counts.
  # We get all boundary sets.
  boundary_sets = BoundarySet.all
  
  # For each boundary set ...
  boundary_sets.each do |boundary_set|
    
    # ... we get all general elections across the boundary set.
    general_elections = boundary_set.general_elections
    
    # We get all the political parties having stood a candidate in that boundary set.
    political_parties = PoliticalParty.find_by_sql(
      "
        SELECT pp.*
        FROM political_parties pp, boundary_set_general_election_party_performances bsgepp
        WHERE pp.id = bsgepp.political_party_id
        AND bsgepp.boundary_set_id = #{boundary_set.id}
        GROUP BY pp.id
      "
    )
    
    # Unless there are no political_parties having stood a candidate in this boundary set ...
    unless political_parties.empty?
      
      # ... for each political party ...
      political_parties.each do |political_party|
        
        # ... for each general election ...
        general_elections.each do |general_election|
          
          # ... we attempt to find a boundary set general election party performance for this party in this general election in this boundary set.
          boundary_set_general_election_party_performance = BoundarySetGeneralElectionPartyPerformance.find_by_sql(
            "
              SELECT bsgepp.*
              FROM boundary_set_general_election_party_performances bsgepp
              WHERE bsgepp.political_party_id = #{political_party.id}
              AND bsgepp.general_election_id = #{general_election.id}
              AND bsgepp.boundary_set_id = #{boundary_set.id}
            "
          ).first
          
          # Unless we find a boundary set general election party performance for this party in this general election in this boundary set ...
          unless boundary_set_general_election_party_performance
            
            # ... we create a new boundary set general election party performance record.
            boundary_set_general_election_party_performance = BoundarySetGeneralElectionPartyPerformance.new
            boundary_set_general_election_party_performance.constituency_contested_count = 0
            boundary_set_general_election_party_performance.constituency_won_count = 0
            boundary_set_general_election_party_performance.cumulative_vote_count = 0
            boundary_set_general_election_party_performance.general_election = general_election
            boundary_set_general_election_party_performance.political_party = political_party
            boundary_set_general_election_party_performance.boundary_set = boundary_set
            boundary_set_general_election_party_performance.save!
          end
        end
      end
    end
  end
end

# ## A task to generate political party switches.
task :generate_political_party_switches => :environment do
  puts "generating political party switches"
  
  # We get all the general elections.
  general_elections = GeneralElection.all
  
  # For each general election ...
  general_elections.each do |general_election|
    
    # ... for each election ...
    general_election.elections.each do |election|
      
      # ... if the election is associated with a result summary ...
      if election.result_summary
      
        # ... we get the boundary set.
        boundary_set = election.boundary_set
      
        # If the election result summary is from the Commons Speaker ...
        if election.result_summary.is_from_commons_speaker == true
        
          # ... we set the from political party name and abbreviation.
          from_political_party_name = 'Speaker'
          from_political_party_abbreviation = 'Spk'
        
        # Otherwise, if the election result summary is from independent ...
        elsif election.result_summary.is_from_independent == true
        
          # ... we set the from political party name and abbreviation.
          from_political_party_name = 'Independent'
          from_political_party_abbreviation = 'Ind'
        
        # Otherwise ...
        else
        
          # ... we set the from political party name and abbreviation to those of the result summary from political party.
          from_political_party_name = election.result_summary.from_political_party.name
          from_political_party_abbreviation = election.result_summary.from_political_party.abbreviation
        end
      
        # If the election result summary is to the Commons Speaker ...
        if election.result_summary.is_to_commons_speaker == true
        
          # ... we set the to political party name and abbreviation.
          to_political_party_name = 'Speaker'
          to_political_party_abbreviation = 'Spk'
        
        # Otherwise, if the election result summary is to independent ...
        elsif election.result_summary.is_to_independent == true
        
          # ... we set the to political party name and abbreviation.
          to_political_party_name = 'Independent'
          to_political_party_abbreviation = 'Ind'
        
        # Otherwise ...
        else
        
          # ... we set the to political party name and abbreviation to those of the result summary to political party.
          to_political_party_name = election.result_summary.to_political_party.name
          to_political_party_abbreviation = election.result_summary.to_political_party.abbreviation
        end
      
        # We look for a political party switch in this general election for this party or parties.
        political_party_switch = PoliticalPartySwitch
          .all
          .where( "general_election_id = ?", general_election.id )
          .where( "from_political_party_name = ?", from_political_party_name )
          .where( "to_political_party_name = ?", to_political_party_name )
          .where( "boundary_set_id = ?", boundary_set.id )
          .first
      
        # Unless we find a political party switch in this general election for this political party or parties ...
        unless political_party_switch
        
          # ... we create a new political party switch.
          political_party_switch = PoliticalPartySwitch.new
          political_party_switch.count = 1
          political_party_switch.from_political_party_name = from_political_party_name
          political_party_switch.from_political_party_abbreviation = from_political_party_abbreviation
          political_party_switch.to_political_party_name = to_political_party_name
          political_party_switch.to_political_party_abbreviation = to_political_party_abbreviation
          political_party_switch.general_election = general_election
          political_party_switch.boundary_set = boundary_set
        
          # If the result summary is associated with a from political party ...
          if election.result_summary.from_political_party_id
          
            # ... we associate the party switch with the from political party.
            political_party_switch.from_political_party_id = election.result_summary.from_political_party_id
          end
        
          # If the result summary is associated with a to political party ...
          if election.result_summary.to_political_party_id
          
            # ... we associate the party switch with the to political party.
            political_party_switch.to_political_party_id = election.result_summary.to_political_party_id
          end
        
        # Otherwise, if we find a political party switch in this general election for this party or parties ...
        else
        
          # ... we increment the count.
          political_party_switch.count += 1
        end
      
        # We save the political party switch.
        political_party_switch.save!
      end
    end
  end
end

# ## A task to generate political party switch nodes and edges.
task :generate_graphviz => :environment do
  puts 'generating political party switch nodes and edges'
  
  # We get all the political party switches.
  political_party_switches = PoliticalPartySwitch.find_by_sql(
    "
      SELECT
        pps.*,
        ge.polling_on AS general_election_polling_on
      FROM political_party_switches pps, general_elections ge
      WHERE ge.id = pps.general_election_id
    "
  )
  
  # For each political party switch ...
  political_party_switches.each do |political_party_switch|
    
    # ... we set the from node label.
    from_node_label = political_party_switch.from_political_party_abbreviation + ' ' + political_party_switch.general_election.preceding_general_election.polling_on.strftime( '%Y' )
    
    # We attempt to find the from node.
    from_node = Node.all.where( "label = ?", from_node_label ).where( "boundary_set_id =?", political_party_switch.boundary_set_id ).first
    
    # Unless we find the from node ...
    unless from_node
      
      # ... we create the from node.
      from_node = Node.new
      from_node.label = from_node_label
      from_node.boundary_set_id = political_party_switch.boundary_set_id
      from_node.save!
    end
    
    # We set the to node label.
    to_node_label = political_party_switch.to_political_party_abbreviation + ' ' + political_party_switch.general_election.polling_on.strftime( '%Y' )
    
    # We attempt to find the to node.
    to_node = Node.all.where( "label = ?", to_node_label ).where( "boundary_set_id =?", political_party_switch.boundary_set_id ).first
    
    # Unless we find the to node ...
    unless to_node
      
      # ... we create the to node.
      to_node = Node.new
      to_node.label = to_node_label
      to_node.boundary_set_id = political_party_switch.boundary_set_id
      to_node.save!
    end
    
    # We create a new edge.
    edge = Edge.new
    edge.count = political_party_switch.count
    edge.from_node_label = from_node_label
    edge.to_node_label = to_node_label
    edge.from_node_id = from_node.id
    edge.to_node_id = to_node.id
    edge.save!
  end
end









# ## A task to import notional results.
task :import_notional_results => :environment do
  puts "importing notional results"
  
  # We find the notional general election.
  general_election = GeneralElection.all.where( 'is_notional IS TRUE' ).first
  
  # For each result ...
  CSV.foreach( 'db/data/results-by-parliament/58/notional-general-election/results.csv' ) do |row|
    
    # ... we store the values from the spreadsheet.
    notional_election_constituency_area_geographic_code = row[2]
    notional_election_country_name = row[5]
    notional_election_turnout = row[7]
    notional_election_electorate_population_count = row[8]
    notional_election_valid_vote_count = row[9]
    notional_election_majority = row[10]
    notional_election_candidacy_party_code = row[11]
    notional_election_candidacy_vote_count = row[12]
    notional_election_candidacy_party_abbreviation = row[13]
    notional_election_candidacy_party_name = row[14].sub( "'", "''" )
    puts notional_election_candidacy_party_name
    notional_election_candidacy_mnis_id = row[15]
    
    # We find the country.
    country = Country.find_by_name( notional_election_country_name )
    
    # We find the boundary set.
    boundary_set = get_boundary_set( country.id, 'new' )
    
    # We find the constituency group.
    constituency_group = ConstituencyGroup.find_by_sql(
      "
        SELECT cg.*
        FROM constituency_groups cg, constituency_areas ca
        WHERE cg.constituency_area_id = ca.id
        AND ca.boundary_set_id = #{boundary_set.id}
        AND ca.geographic_code = '#{notional_election_constituency_area_geographic_code}'
      "
    ).first
    
    # We attempt to find the electorate.
    electorate = Electorate.find_by_sql(
      "
        SELECT *
        FROM electorates
        WHERE constituency_group_id = #{constituency_group.id}
        AND population_count = #{notional_election_electorate_population_count}
      "
    ).first
    
    # Unless we find the electorate ...
    unless electorate
      
      # ... we create a new electorate.
      electorate = Electorate.new
      electorate.population_count = notional_election_electorate_population_count
      electorate.constituency_group = constituency_group
      #electorate.save!
    end
    
    # We attempt to find the election ...
    election = Election.find_by_sql(
      "
        SELECT * 
        FROM elections
        WHERE general_election_id = #{general_election.id}
        AND constituency_group_id = #{constituency_group.id}
      "
    ).first
    
    # Unless we find the election ...
    unless election
      
      # ... we create a new election
      election = Election.new
      election.polling_on = general_election.polling_on
      election.is_notional = true
      election.valid_vote_count = notional_election_valid_vote_count
      election.majority = notional_election_majority
      election.constituency_group = constituency_group
      election.general_election = general_election
      election.electorate = electorate
      election.parliament_period = general_election.parliament_period
      #election.save!
    end
    
    # If the MNIS ID is recorded as 'NA' ...
    if notional_election_candidacy_mnis_id == 'NA'
      
      # NOTE: todo - deal with 'other' parties!
      # Lists max other and total other
      puts notional_election_candidacy_party_code unless notional_election_candidacy_party_code == 'TOTOTHV' or notional_election_candidacy_party_code == 'MAXOTHV'
      
    # Otherwise, if the MNIS ID is not recorded as 'NA' ...
    else
      
      # ... we attempt to find the political party.
      political_party = PoliticalParty.find_by_sql(
        "
          SELECT *
          FROM political_parties
          WHERE name = '#{notional_election_candidacy_party_name}'
        "
      )
      puts political_party.size
    end
  end
end






# ## A method to import election candidacy results.
def import_election_candidacy_results( parliament_number, polling_on )
  puts "importing election candidacy results for #{polling_on} general election"
  
  # We find the general election this election forms part of.
  general_election = GeneralElection.find_by_polling_on( polling_on )
  
  # For each row in the results sheet ...
  CSV.foreach( "db/data/results-by-parliament/#{parliament_number}/general-election/candidacies.csv" ) do |row|
    
    # ... we store the values from the spreadsheet.
    candidacy_constituency_area_geographic_code = row[0]
    candidacy_english_region_geographic_code = row[1]
    candidacy_constituency_area_name = row[2]
    candidacy_county_name = row[3] # We're ignoring this field because proposed constituencies will no longer fit into county geographies.
    candidacy_english_region_geographic_name = row[4]
    candidacy_country = row[5]
    candidacy_constituency_area_type = row[6]
    candidacy_main_political_party_name = row[7]
    candidacy_main_political_party_abbreviation = row[8]
    candidacy_main_political_party_electoral_commission_id = row[9]
    candidacy_adjunct_political_party_electoral_commission_id = row[10]
    candidacy_candidate_given_name = row[11]
    candidacy_candidate_family_name = row[12]
    candidacy_candidate_gender = row[13]
    candidacy_candidate_is_sitting_mp = row[14]
    candidacy_candidate_is_former_mp = row[15]
    candidacy_candidate_mnis_member_id = row[16]
    candidacy_vote_count = row[17]
    candidacy_vote_share = row[18]
    candidacy_vote_change = row[19]
    
    # We check if the country exists.
    country = Country.find_by_name( candidacy_country )
    
    # If the country is England ...
    if country.name == 'England'
    
      # ... we check if the English region exists.
      english_region = EnglishRegion.find_by_geographic_code( candidacy_english_region_geographic_code )
      
      # If the English region does not exist ...
      unless english_region
        
        # ... we create the English region.
        english_region = EnglishRegion.new
        english_region.name = candidacy_english_region_geographic_name
        english_region.geographic_code = candidacy_english_region_geographic_code
        english_region.country = country
        english_region.save!
      end
    end
    
    # We check if the constituency area type exists.
    constituency_area_type = ConstituencyAreaType.find_by_area_type( candidacy_constituency_area_type )
    
    # If the constituency area type does not exist ...
    unless constituency_area_type
      
      # ... we create the constituency area type.
      constituency_area_type = ConstituencyAreaType.new
      constituency_area_type.area_type = candidacy_constituency_area_type
      constituency_area_type.save!
    end
    
    # We check if there's a constituency area with this geographic code.
    constituency_area = ConstituencyArea.find_by_geographic_code( candidacy_constituency_area_geographic_code )
    
    # If there's no constituency area with this geographic code ...
    unless constituency_area
      
      # ... we create the constituency area ...
      constituency_area = ConstituencyArea.new
      constituency_area.name = candidacy_constituency_area_name
      constituency_area.geographic_code = candidacy_constituency_area_geographic_code
      constituency_area.constituency_area_type = constituency_area_type
      constituency_area.country = country
      constituency_area.english_region = english_region if english_region
      constituency_area.save!
    end
    
    # We check if there's a constituency group with a constituency area with this geographic code.
    constituency_group = ConstituencyGroup.find_by_sql(
      "
        SELECT cg.*
        FROM constituency_groups cg, constituency_areas ca
        WHERE cg.constituency_area_id = ca.id
        AND ca.geographic_code = '#{candidacy_constituency_area_geographic_code}'
      "
    ).first
    
    # Unless we find a constituency group with a constituency area with this ONS code ...
    unless constituency_group
      
      # ... we create the constituency group.
      constituency_group = ConstituencyGroup.new
      constituency_group.name = candidacy_constituency_area_name
      constituency_group.constituency_area = constituency_area
      constituency_group.save!
    end
    
    # We check if there's an election forming part of this general election for this constituency group.
    election = Election.find_by_sql(
      "
        SELECT e.*
        FROM elections e, constituency_groups cg
        WHERE e.constituency_group_id = cg.id
        AND cg.constituency_area_id = #{constituency_area.id}
        AND e.general_election_id = #{general_election.id}
      "
    ).first
    
    # If there's no election forming part of this general election for this constituency group ...
    unless election
      
      # ... we find the Parliament period this election was in to.
      parliament_period = get_parliament_period( polling_on )
      
      # ... we create the election.
      election = Election.new
      election.polling_on = polling_on
      election.constituency_group = constituency_group
      election.general_election = general_election
      election.parliament_period = parliament_period
      election.save!
    end
    
    # We find the gender of the candidate.
    gender = Gender.find_by_gender( candidacy_candidate_gender )
    
    # If the candidate has a MNIS Member ID ...
    if candidacy_candidate_mnis_member_id
      
      # ... we attempt to find the Member with this MNIS ID.
      member = Member.find_by_mnis_id( candidacy_candidate_mnis_member_id )
      
      # Unless we find the Member ...
      unless member
        
        # ... we create the Member.
        member = Member.new
        member.given_name = candidacy_candidate_given_name
        member.family_name = candidacy_candidate_family_name
        member.mnis_id = candidacy_candidate_mnis_member_id
        member.save
      end
    end
    
    # We create a candidacy.
    candidacy = Candidacy.new
    candidacy.candidate_given_name = candidacy_candidate_given_name
    candidacy.candidate_family_name = candidacy_candidate_family_name
    candidacy.member = member if member
    candidacy.candidate_is_sitting_mp = candidacy_candidate_is_sitting_mp
    candidacy.candidate_is_former_mp = candidacy_candidate_is_former_mp
    candidacy.candidate_gender = gender
    candidacy.election = election
    candidacy.vote_count = candidacy_vote_count
    candidacy.vote_share = candidacy_vote_share
    candidacy.vote_change = candidacy_vote_change
    
    # If the party name is Independent ...
    if candidacy_main_political_party_name == 'Independent'
      
      # ... we flag the candidacy as standing as independent.
      candidacy.is_standing_as_independent = true
      
    # Otherwise, if the party name is Speaker ...
    elsif candidacy_main_political_party_name == 'Speaker'
      
      # ... we flag the candidacy as standing as Commons Speaker.
      candidacy.is_standing_as_commons_speaker = true
      
    # Otherwise, if the candidacy has an adjunct political party certification ...
    # ... we know this is a Labour / Co-op candidacy ...
    elsif candidacy_adjunct_political_party_electoral_commission_id
      
      # ... we check if the main political party exists.
      political_party = PoliticalParty.find_by_electoral_commission_id( candidacy_main_political_party_electoral_commission_id )
      
      # If the main political party does not exist.
      unless political_party
        
        # ... we create it.
        political_party = PoliticalParty.new
        political_party.name = 'Labour'
        political_party.abbreviation = 'Lab'
        political_party.electoral_commission_id = candidacy_main_political_party_electoral_commission_id
        political_party.save
      end
        
      # We create a certification of the candidacy by the political party.
      certification1 = Certification.new
      certification1.candidacy = candidacy
      certification1.political_party = political_party
      certification1.save!
      
      # We check if the adjunct political party exists.
      political_party = PoliticalParty.find_by_electoral_commission_id( candidacy_adjunct_political_party_electoral_commission_id )
      
      # If the adjunct political party does not exist.
      unless political_party
        
        # ... we create it.
        political_party = PoliticalParty.new
        political_party.name = 'Co-operative'
        political_party.abbreviation = 'Co-op'
        political_party.electoral_commission_id = candidacy_adjunct_political_party_electoral_commission_id
        political_party.save
      end
        
      # We create a certification of the candidacy by the political party ...
      certification2 = Certification.new
      certification2.candidacy = candidacy
      certification2.political_party = political_party
    
      # ... making it adjunct to the certification by the Labour Party.
      certification2.adjunct_to_certification_id = certification1.id
      certification2.save!
      
    # Otherwise, if the candidacy does not have an adjunct political party certification ...
    # ... we know this is not The Speaker, not an independent candidacy and not a Labour / Co-op candidacy ...
    else
      
      # ... so we check if a political party with that name and abbreviation exists ...
      # ... because we know older political parties may not have an Electoral Commission ID.
      political_party = PoliticalParty
        .all
        .where( "name = ?", candidacy_main_political_party_name )
        .where( "abbreviation = ?", candidacy_main_political_party_abbreviation )
        .first
        
      # If the political party does not exist ...
      unless political_party
        
        # ... we create it.
        political_party = PoliticalParty.new
        political_party.name = candidacy_main_political_party_name
        political_party.abbreviation = candidacy_main_political_party_abbreviation
        political_party.electoral_commission_id = candidacy_main_political_party_electoral_commission_id
        political_party.save!
      end
      
      # We create a certification of the candidacy by the party.
      certification = Certification.new
      certification.candidacy = candidacy
      certification.political_party = political_party
      certification.save!
    end
    
    # We save the candidacy.
    candidacy.save!
  end
end

# ## A method to import election constituency results with a named winner.
def import_election_constituency_results( parliament_number, polling_on )
  puts "importing election constituency results for #{polling_on} general election"
  
  # We find the general election this election forms part of.
  general_election = GeneralElection.find_by_polling_on( polling_on )
  
  # For each row in the results sheet ...
  CSV.foreach( "db/data/results-by-parliament/#{parliament_number}/general-election/constituencies.csv" ) do |row|
    
    # We store the new data we want to capture in the database.
    election_declaration_at = row[7]
    election_result_type = row[11]
    election_valid_vote_count = row[15]
    election_invalid_vote_count = row[16]
    election_majority = row[17]
    electorate_count = row[14]
    
    # We store the data we need to find the candidacy, quoted for SQL.
    candidacy_candidate_family_name = ActiveRecord::Base.connection.quote( row[9] )
    candidacy_candidate_given_name = ActiveRecord::Base.connection.quote( row[8] )
    constituency_area_geographic_code = ActiveRecord::Base.connection.quote( row[0] )
    
    # We find the candidacy.
    # NOTE: this works on the assumption that the name of the winning candidate standing in a given general election in a constituency with a given geographic code is unique, which appears to be true.
    candidacy = Candidacy.find_by_sql(
      "
        SELECT c.*
        FROM candidacies c, elections e, constituency_groups cg, constituency_areas ca
        WHERE c.candidate_given_name = #{candidacy_candidate_given_name}
        AND c.candidate_family_name = #{candidacy_candidate_family_name}
        AND c.election_id = e.id
        AND e.general_election_id = #{general_election.id}
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.geographic_code = #{constituency_area_geographic_code}
        ORDER BY c.vote_count DESC
      "
    ).first
    
    # We annotate the election results.
    annotate_election_results( candidacy, election_result_type, election_valid_vote_count, election_invalid_vote_count, election_majority, electorate_count, election_declaration_at )
  end
end

# ## A method to annotate elections with constituency level results.
def annotate_election_results( candidacy, election_result_type, election_valid_vote_count, election_invalid_vote_count, election_majority, electorate_count, election_declaration_at )
  
  # We mark the candidacy as being the winning candidacy.
  candidacy.is_winning_candidacy = true
  candidacy.save
  
  # We attempt to find the result summary.
  result_summary = ResultSummary.find_by_short_summary( election_result_type )
  
  # Unless we fine the result summary ...
  unless result_summary
    
    # ... we create the result summary.
    result_summary = ResultSummary.new
    result_summary.short_summary = election_result_type
    result_summary.save
  end
  
  # We attempt to find an elecorate for this constituency group with this population count.
  electorate = Electorate.all.where( "population_count = ?", electorate_count ).where( "constituency_group_id = ?", candidacy.election.constituency_group_id ).first
  
  # Unless we find an elecorate for this constituency group with this population count ...
  unless electorate
  
    # ... we create a new electorate.
    electorate = Electorate.new
    electorate.population_count = electorate_count
    electorate.constituency_group = candidacy.election.constituency_group
    electorate.save!
  end
  
  # We add annotate the election with new properties.
  candidacy.election.valid_vote_count = election_valid_vote_count
  candidacy.election.invalid_vote_count = election_invalid_vote_count
  candidacy.election.majority = election_majority
  candidacy.election.result_summary = result_summary
  candidacy.election.electorate = electorate
  candidacy.election.declaration_at = election_declaration_at
  candidacy.election.save!
end

# ## A method to get the Parliament period for a polling date.
def get_parliament_period( polling_on )
  
  # We get all the Parliament periods ending after this polling date.
  ParliamentPeriod.find_by_sql(
    "
      SELECT *
      FROM parliament_periods
      WHERE (
        dissolved_on > '#{polling_on}'
        OR
        dissolved_on IS NULL /* accounting for a NULL dissolution date on the current Parliament period */
      )
      ORDER BY summoned_on /* ordering earliest first */
    "
  ).first # choosing the first
end

# ## A method to get the boundary set for a constituency area for assorted situations.
def get_boundary_set( country_id, mode )
  
  # If dissolution has happened ...
  if has_dissolution_happened?
    
    # ... if we're looking for an 'old' boundary set ...
    if mode == 'old'
    
      # ... we find the latest boundary set for this country having a start date and an end date.
      boundary_set = BoundarySet.find_by_sql(
        "
          SELECT *
          FROM boundary_sets
          WHERE country_id = #{country_id}
          AND start_on IS NOT NULL
          AND end_on IS NOT NULL
          ORDER BY start_on DESC
        "
      ).first
      
    # Otherwise, if we're looking for a 'new' constituency ...
    elsif mode == 'new'
    
      # ... we find the boundary set for this country having a start date and a NULL end date.
      boundary_set = BoundarySet.find_by_sql(
        "
          SELECT *
          FROM boundary_sets
          WHERE country_id = #{country_id}
          AND start_on IS NOT NULL
          AND end_on IS NULL
          ORDER BY start_on DESC
        "
      ).first
    end
    
  # Otherwise, if dissolution has not happened ...
  else
    
    # ... if we're looking for an 'old' boundary set ...
    if mode == 'old'
    
      # ... we find the boundary set for this country having a start date and a NULL end date.
      boundary_set = BoundarySet.find_by_sql(
        "
          SELECT *
          FROM boundary_sets
          WHERE country_id = #{country_id}
          AND start_on IS NOT NULL
          AND end_on IS NULL
          ORDER BY start_on DESC
        "
      ).first
      
    # Otherwise, if we're looking for a new constituency ...
    elsif mode == 'new'
    
      # ... we find the boundary set for this country having a NULL start date and a NULL end date.
      boundary_set = BoundarySet.find_by_sql(
        "
          SELECT *
          FROM boundary_sets
          WHERE country_id = #{country_id}
          AND start_on IS NULL
          AND end_on IS NULL
          ORDER BY start_on DESC
        "
      ).first
    end
  end
  
  # We return the boundary set.
  boundary_set
end

# ## A method to calculate if dissolution has happened yet ...
def has_dissolution_happened?
  
  # We create the variable to hold the dissolution boolean and set it to false by default.
  has_dissolution_happened = false
  
  # When the next dissolution is announced, we'll know the end date of the 'current' boundary sets and the start date of the next boundary sets.
  # Until then, the start dates of the next boundary sets are NULL and the end dates of both the 'current' boundary sets and the next boundary sets are NULL.
  
  # We find all boundary sets with a NULL end date.
  unended_boundary_sets = BoundarySet.find_by_sql(
    "
      SELECT *
      FROM boundary_sets
      WHERE end_on IS NULL
    "
  )
  
  # If there are four boundary sets with a NULL end date ...
  if unended_boundary_sets.size == 4
    
    # ... we know dissolution has happened, the 'old' boundary sets have been closed and the new boundary sets have been started ...
    # ... the four boundary sets returned being for England, Wales, Scotland and Northern Ireland.
    # .. so we set the dissolution variable to true.
    has_dissolution_happened = true
  end
  
  # We return the dissolution variable.
  has_dissolution_happened
end