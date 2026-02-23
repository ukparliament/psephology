task :populate_constituency_group_sets => [
  :populate_missing_constituency_group_sets,
  :attach_child_constituency_group_sets,
  :attach_constituency_groups_to_constituency_group_sets
]

# ## A task to populate missing constituency group sets.
task :populate_missing_constituency_group_sets => :environment do
  puts "populating missing constituency group sets"

  # We find all boundary sets.
  boundary_sets = BoundarySet.all
  
  # For each boundary set ...
  boundary_sets.each do |boundary_set|
  
    # If the boundary set has no end date.
    if boundary_set.end_on.nil?
    
      # ... we attempt to find an equivalent constituency group set with that no date.
      constituency_group_set = ConstituencyGroupSet.find_by_sql([
        "
          SELECT *
          FROM constituency_group_sets
          WHERE start_on = ?
          AND end_on IS NULL
          AND country_id = ?
        ", boundary_set.start_on, boundary_set.country_id
      ]).first
    
    # Otherwise, if the boundary set has an end date.
    else
    
      # ... we attempt to find an equivalent constituency group set with that end date.
      constituency_group_set = ConstituencyGroupSet.find_by_sql([
        "
          SELECT *
          FROM constituency_group_sets
          WHERE start_on = ?
          AND end_on = ?
          AND country_id = ?
        ", boundary_set.start_on, boundary_set.end_on, boundary_set.country_id
      ]).first
    end
    
    # Unless we find a constituency group set ...
    unless constituency_group_set
      
      # ... we create a new constituency group set with the same details as the boundary set
      constituency_group_set = ConstituencyGroupSet.new
      constituency_group_set.description = boundary_set.description
      constituency_group_set.start_on = boundary_set.start_on
      constituency_group_set.end_on = boundary_set.end_on
      constituency_group_set.country_id = boundary_set.country_id
      constituency_group_set.save!
      
      # For each boundary set legislation item ...
      boundary_set.boundary_set_legislation_items.each do |bsli|
      
        # ... we create a new constituency group set legislation item.
        constituency_group_set_legislation_item = ConstituencyGroupSetLegislationItem.new
        constituency_group_set_legislation_item.constituency_group_set_id = constituency_group_set.id
        constituency_group_set_legislation_item.legislation_item_id = bsli.legislation_item_id
        constituency_group_set_legislation_item.save!
      end
    end
  end
end

# ## A task to attach child constituency group sets to their parents.
task :attach_child_constituency_group_sets => :environment do
  puts "attaching child constituency group sets"
  
  # We find both constituency groups sets with a description.
  constituency_group_sets = ConstituencyGroupSet.where( 'description is not null' )
  
  # For each constituency group set with a description ...
  constituency_group_sets.each do |constituency_group_set|
  
    # ... we set the parent.
    constituency_group_set.parent_constituency_group_set_id = 33
    constituency_group_set.save!
  end
end

# ## A task to attach constitituency groups to constituency group sets.
task :attach_constituency_groups_to_constituency_group_sets => :environment do
  puts "attaching constituency groups to constituency group sets"
  
  # We find all constituency groups not attached to a constituency group set.
  constituency_groups = ConstituencyGroup.where( 'constituency_group_set_id IS NULL' )
  
  # For each constituency group not attached to a constituency group set ...
  constituency_groups.each do |constituency_group|
  
    # ... we find the appropriate constituency group set.
    constituency_group_set = ConstituencyGroupSet.find_by_sql([
      "
        SELECT cgs.*
        FROM constituency_areas ca, boundary_sets bs, boundary_set_legislation_items bsli, legislation_items li, constituency_group_set_legislation_items cgsli, constituency_group_sets cgs
        WHERE ca.id = ?
        AND ca.boundary_set_id = bs.id
        AND bs.id = bsli.boundary_set_id
        AND bsli.legislation_item_id = li.id
        AND li.id = cgsli.legislation_item_id
        AND cgsli.constituency_group_set_id = cgs.id
      ", constituency_group.constituency_area_id
    ]).first
    
    # We associate the constituency group with its constituency group set.
    constituency_group.constituency_group_set = constituency_group_set
    constituency_group.save!
  end
end