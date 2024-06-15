require 'csv'

task :post_2010_tidies => [
  :post_2010_tidies_update_parliaments
]

# ## A task to update Parliaments.
task :post_2010_tidies_update_parliaments => :environment do
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
    
    # We find the Parliament.
    parliament_period = ParliamentPeriod.find_by_number( parliament_number )
    parliament_period.summoned_on = parliament_summoned_on
    parliament_period.dissolved_on = parliament_dissolved_on
    parliament_period.state_opening_on = parliament_state_opening_on
    parliament_period.wikidata_id = parliament_wikidata_id
    parliament_period.london_gazette = parliament_london_gazette
    parliament_period.save!
  end
end