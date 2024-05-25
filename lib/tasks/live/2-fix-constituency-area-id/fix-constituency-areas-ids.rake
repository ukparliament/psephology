# ## A task to fix constituency area IDs.

# Under boundary changes in 2024, the ONS minted new identifiers for all constituency areas in England, Wales and Northern Ireland regardless of whether their boundaries had changed.
# Under boundary changes in Scotland, only constituency areas with changed boundaries were given new identifiers.
# This changed on 2024-05-23 when the ONS issued new geographic codes to five - not all - of the Scottish constituencies with unchanged boundaries.
# This script patches that.

task :fix_constituency_area_ids => :environment do
  puts "fixing constituency area ONS IDs"
  
  # We find the new Scottish boundary set.
  boundary_set = BoundarySet.find( 3 )
  
  # For each revised constituency area ID ...
  CSV.foreach( 'db/data/revised_constituency_ids.csv' ) do |row|
    
    # ... we attempt to find the constituency area.
    constituency_area = ConstituencyArea.find_by_sql(
      "
        SELECT *
        FROM constituency_areas
        WHERE geographic_code = '#{row[0]}'
        AND boundary_set_id = #{boundary_set.id}
      "
    ).first
    
    # We give the constituency area its new ID.
    constituency_area.geographic_code = row[2]
    constituency_area.save!
  end
end