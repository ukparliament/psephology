require 'csv'

task :import_1997_constituencies => :environment do
  puts 'importing 1997 constituencies'

  # We set the path to the constituencies file.
  constituencies_file = "db/data/constituencies/1997.csv"

  # For each row in the sheet ...
  CSV.foreach( constituencies_file ).with_index do |row, index|
    next if index == 0 # Skip the first row
    
    # We store the data we need to create the constituency.
    constituency_geographic_code = row[0].strip
    constituency_mnis_id = row[2].strip
    constituency_name = row[3].strip
    constituency_area_type_label = row[5].strip
    english_region_geographic_code = row[6].strip if row[6]
    country_geographic_code = row[8].strip
    
    # We find the constituency area type.
    constituency_area_type = ConstituencyAreaType.find_by_area_type( constituency_area_type_label )

    # We find the country the constituency area is in.
    country = Country.find_by_geographic_code( country_geographic_code )
    
    # If the constituency area is in an English region ...
    if english_region_geographic_code

      # ... we find the English region the constituency area is in.
      english_region = EnglishRegion.find_by_geographic_code( english_region_geographic_code )
    end
    
    # We find the boundary set the constituency area is in.
    boundary_set = BoundarySet.find_by_sql(
      "
        SELECT bs.*
        FROM boundary_sets bs
        WHERE bs.country_id = #{country.id}
        AND bs.start_on = '1997-04-09' /* The start date of the 1997 constituencies for all four nations. */
      "
    ).first
    
    # We attempt to find a constituency area with this geographic area code in this boundary set.
    constituency_area = ConstituencyArea.find_by_sql(
      "
        SELECT *
        FROM constituency_areas
        WHERE geographic_code = '#{constituency_geographic_code}'
        AND boundary_set_id = #{boundary_set.id}
      "
    ).first
    
    # Unless we find a constituency area with this geographic area code in this boundary set ...
    unless constituency_area

      # ... we create the constituency area.
      constituency_area = ConstituencyArea.new
      constituency_area.geographic_code = constituency_geographic_code
      constituency_area.country = country
      constituency_area.boundary_set = boundary_set
    end
    
    # We create or update the constituency area attributes.
    constituency_area.name = constituency_name
    constituency_area.english_region = english_region if english_region
    constituency_area.constituency_area_type = constituency_area_type
    constituency_area.mnis_id = constituency_mnis_id
    
    # If the constituency area is in Northern Ireland or Scotland ...
    if country.name == 'Northern Ireland' || country.name == 'Scotland'
    
      # ... we flag the constituency area geographic code was not issued by the ONS.
      constituency_area.is_geographic_code_issued_by_ons = false
    end
    constituency_area.save!
    
    # Having created the constituency area, we attempt to find its accompanying constituency group.
    constituency_group = ConstituencyGroup.find_by_constituency_area_id( constituency_area.id )

    # Unless we find the accompanying constituency group ...
    unless constituency_group

      # ... we create the constituency group.
      constituency_group = ConstituencyGroup.new
      constituency_group.constituency_area = constituency_area
    end
    
    # We create or update the constituency group attributes.
    constituency_group.name = constituency_name
    constituency_group.save!
    
    # We attempt to find a constituency group set with the same dates and country as the boundary set.
    constituency_group_set = ConstituencyGroupSet.find_by_sql(
      "
        SELECT cgs.*
        FROM constituency_group_sets cgs
        WHERE cgs.start_on = '#{boundary_set.start_on}'
        AND cgs.end_on = '#{boundary_set.end_on}'
        AND cgs.country_id = #{boundary_set.country_id}
      "
    ).first
    
    # Unless we find a constituency group set with the same dates and country as the boundary set ...
    unless constituency_group_set

      # ... we create it.
      constituency_group_set = ConstituencyGroupSet.new
      constituency_group_set.start_on = boundary_set.start_on
      constituency_group_set.end_on = boundary_set.end_on
      constituency_group_set.country_id = boundary_set.country_id
      constituency_group_set.save!
    end
    
    # We get the legislation items establing the boundary set.
    legislation_items = LegislationItem.find_by_sql(
      "
        SELECT li.*
        FROM legislation_items li, boundary_set_legislation_items bsli
        WHERE li.id = bsli.legislation_item_id
        AND bsli.boundary_set_id = #{boundary_set.id}
      "
    )
    
    # For each legislation item establing the boundary set ...
    legislation_items.each do |legislation_item|
    
      # ... we attempt to find a constituency group set legislation item for this legislation item and this constituency group set.
      constituency_group_set_legislation_item = ConstituencyGroupSetLegislationItem.find_by_sql(
        "
          SELECT *
          FROM constituency_group_set_legislation_items
          WHERE constituency_group_set_id = #{constituency_group_set.id}
          AND legislation_item_id = #{legislation_item.id}
        "
      ).first
      
      # Unless we find a constituency group set legislation item for this legislation item and this constituency group set ...
      unless constituency_group_set_legislation_item
  
        # ... we create a constituency group set legislation item for this legislation item and this constituency group set.
        constituency_group_set_legislation_item = ConstituencyGroupSetLegislationItem.new
        constituency_group_set_legislation_item.constituency_group_set = constituency_group_set
        constituency_group_set_legislation_item.legislation_item = legislation_item
        constituency_group_set_legislation_item.save!
      end
    end
  end
end