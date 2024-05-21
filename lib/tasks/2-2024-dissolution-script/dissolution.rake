require 'csv'

task :dissolution => [
  :update_parliament_periods,
  :close_previous_boundary_sets,
  :close_previous_constituency_group_sets,
  :open_new_boundary_sets,
  :open_new_constituency_group_sets
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

# ## A task to close previous boundary sets.
task :close_previous_boundary_sets => :environment do
  puts "closing previous boundary sets"

  # We find the date of dissolution of the previous Parliament period.
  dissolution_date = get_dissolution_date_of_previous_parliament_period
  
  # We find all the previous boundary sets.
  # Those having a start date but no end on date.
  previous_boundary_sets = BoundarySet.all.where( 'start_on IS NOT NULL' ).where( 'end_on IS NULL' )
  
  # For each previous boundary set ...
  previous_boundary_sets.each do |previous_boundary_set|
    
    # ... we set the end date to the date of dissolution.
    previous_boundary_set.end_on = dissolution_date
    previous_boundary_set.save!
  end
end

# ## A task to close previous constituency group sets.
task :close_previous_constituency_group_sets => :environment do
  puts "closing previous constituency group sets"

  # We find the date of dissolution of the previous Parliament period.
  dissolution_date = get_dissolution_date_of_previous_parliament_period
  
  # We find all the previous constituency group sets.
  # Those having a start date but no end on date.
  previous_constituency_group_sets = ConstituencyGroupSet.all.where( 'start_on IS NOT NULL' ).where( 'end_on IS NULL' )
  
  # For each previous constituency group set ...
  previous_constituency_group_sets.each do |previous_constituency_group_set|
    
    # ... we set the end date to the date of dissolution.
    previous_constituency_group_set.end_on = dissolution_date
    previous_constituency_group_set.save!
  end
end

# ## A task to open new boundary sets.
task :open_new_boundary_sets => :environment do
  puts "open new boundary sets"

  # We find the date of dissolution of the previous Parliament period.
  dissolution_date = get_dissolution_date_of_previous_parliament_period
  
  # We work on the assumption that new boundary sets start on the day following dissolution, so we add one day to the dissolution date to get the start date.
  start_date = dissolution_date + 1.day
  
  # We find all the new boundary sets.
  # Those having no start date and no end date.
  new_boundary_sets = BoundarySet.all.where( 'start_on IS NULL' ).where( 'end_on IS NULL' )
  
  # For each new boundary set ...
  new_boundary_sets.each do |new_boundary_set|
    
    # ... we set the start date to the date following the date of dissolution.
    new_boundary_set.start_on = start_date
    new_boundary_set.save!
  end
end

# ## A task to open new constituency group sets.
task :open_new_constituency_group_sets => :environment do
  puts "open new constituency group sets"

  # We find the date of dissolution of the previous Parliament period.
  dissolution_date = get_dissolution_date_of_previous_parliament_period
  
  # We work on the assumption that new constituency group sets start on the day following dissolution, so we add one day to the dissolution date to get the start date.
  start_date = dissolution_date + 1.day
  
  # We find all the new constituency group sets.
  # Those having no start date and no end date.
  new_constituency_group_sets = ConstituencyGroupSet.all.where( 'start_on IS NULL' ).where( 'end_on IS NULL' )
  
  # For each new constituency group set ...
  new_constituency_group_sets.each do |new_constituency_group_set|
    
    # ... we set the start date to the date following the date of dissolution.
    new_constituency_group_set.start_on = start_date
    new_constituency_group_set.save!
  end
end



# ## A method to get the dissolution date of the previous Parliament period.
def get_dissolution_date_of_previous_parliament_period
  
  # We get the previous Parliament period.
  previous_parliament_period = ParliamentPeriod.all.where( 'dissolved_on IS NOT NULL' ).order( 'summoned_on DESC' ).first
  
  # We return the dissolution date of the previous Parliament period.
  previous_parliament_period.dissolved_on
end