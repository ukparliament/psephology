task :align_constituencies_to_mnis => [
  :align_constituency_names_to_mnis,
  :import_missing_mnis_constituency_ids
]

task :align_constituency_names_to_mnis => :environment do
	puts "aligning constituency names to mnis"
  
  # We set the path to the constituencies file.
  constituencies_file = "db/data/constituencies/1997-2024.csv"

  # For each row in the sheet ...
  CSV.foreach( constituencies_file ).with_index do |row, index|
    next if index == 0 # Skip the first row
    
    # We store the variables we need to find the constituency group.
    constituency_name = ActiveRecord::Base.connection.quote( row[0].strip )
    constituency_area_geographic_code = row[1].strip if row[1]
    boundary_set_start_date = row[3].to_date
    
    # We attempt to find the constituency group by matching on the lower case constituency name and the start date of the boundary set.
    constituency_group = ConstituencyGroup.find_by_sql(
      "
        SELECT cg.*
        FROM constituency_groups cg, constituency_areas ca, boundary_sets bs
        WHERE cg.constituency_area_id = ca.id
        AND ca.boundary_set_id = bs.id
        AND bs.start_on = '#{boundary_set_start_date}'
        AND LOWER( cg.name ) = #{constituency_name.downcase}
      "
    )
        
    # If we don't find one constituency group ...
    if constituency_group.size != 1
    
      # ... we report there's been an error matching.
      puts "Constituency #{constituency_name} not found in #{boundary_set_start_date} boundary set."
    
    # Otherwise, if we find one constituency group ...
    else
    
      # ... we set the constituency group to be the first constituency group from the array of one.
      constituency_group = constituency_group.first
    
      # If the constituency name from the MNIS spreadsheet does not match the constituency name in the database ...
      if row[0].strip != constituency_group.name
      
        # ... we flag an alert that the constituency names don't match
        puts "MNIS #{row[0].strip} does not match election results #{constituency_group.name}"
      
        # We update the name of the constituency group to match MNIS ...
        constituency_group.name = row[0].strip
        constituency_group.save!
        
        # ... and update the name of the constituency area to match MNIS.
        constituency_group.constituency_area.name = row[0].strip
        constituency_group.constituency_area.save!
      end
    end
  end
end

task :import_missing_mnis_constituency_ids => :environment do
	puts "importing missing mnis constituency ids"
  
  # We set the path to the constituencies file.
  constituencies_file = "db/data/constituencies/1997-2024.csv"

  # For each row in the sheet ...
  CSV.foreach( constituencies_file ).with_index do |row, index|
    next if index == 0 # Skip the first row
    
    # We store the variables we need to find the constituency area.
    constituency_name = ActiveRecord::Base.connection.quote( row[0].strip )
    constituency_area_geographic_code = row[1].strip if row[1]
    constituency_area_mnis_id = row[2].strip if row[2]
    boundary_set_start_date = row[3].to_date
    
    # We attempt to find the constituency area by matching on the constituency name and the start date of the boundary set.
    constituency_area = ConstituencyArea.find_by_sql(
      "
        SELECT ca.*
        FROM constituency_areas ca, boundary_sets bs
        WHERE ca.boundary_set_id = bs.id
        AND bs.start_on = '#{boundary_set_start_date}'
        AND ca.name = #{constituency_name}
      "
    )
        
    # If we don't find one constituency area ...
    if constituency_area.size != 1
    
      # ... we report there's been an error matching.
      puts "Constituency #{constituency_name} not found in #{boundary_set_start_date} boundary set."
    
    # Otherwise, if we find one constituency group ...
    else
    
      # ... we set the constituency area to be the first constituency area from the array of one.
      constituency_area = constituency_area.first
      
      # If the constituency area has a mnis id ...
      if constituency_area.mnis_id
      
        # ... if the constituency area mnis id does not match the id in the spreadsheet ...
        if constituency_area.mnis_id != constituency_area_mnis_id.to_i
        
          # ... we flag an error. 
          puts "Constituency area mnis id in database #{constituency_area.mnis_id} does not match mnis id in spreadsheet #{constituency_area_mnis_id}"
        end
        
      # Otherwise, if the constituency area does not have a mnis id ...
      else
      
        # ... we add the mnis id from the spreadsheet to the constituency area.
        constituency_area.mnis_id = constituency_area_mnis_id
        constituency_area.save!
      end
    end
  end
end



