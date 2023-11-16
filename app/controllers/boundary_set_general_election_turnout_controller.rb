class BoundarySetGeneralElectionTurnoutController < ApplicationController
  
  def index
    boundary_set = params[:boundary_set]
    
    @boundary_set = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name, li.title AS legislation_item_title
        FROM boundary_sets bs, legislation_items li, countries c
        WHERE bs.legislation_item_id = li.id
        AND bs.country_id = c.id
        AND bs.id = #{boundary_set}
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @boundary_set
    
    # We get all the general elections held during the duration of the boundary set.
    @general_elections = @boundary_set.general_elections
    
    # We get all constitutionary areas defined by this boundary set.
    @constituency_areas = @boundary_set.constituency_areas
    
    # We get all elections held in a constituency area defined by the boundary set.
    @elections = @boundary_set.elections_with_electorate
    
    # For each constitutionary area defined by the boundary set ...
    @constituency_areas.each do |constituency_area|
      
      # ... we create a - fake - constituency area attribute to hold an array of elections in that constituency area.
      constituency_area.election_array = []
      
      # For each election held in a constituency area defined by the boundary set ...
      @elections.each do |election|
        
        # ... if the constituency area of the election is this constituency area ...
        if election.constituency_area_id == constituency_area.id
          
          # ... we add the election to the constituency area election array.
          constituency_area.election_array << election
        end
      end
    end
    @page_title = "Boundary set for #{@boundary_set.display_title} - general election constituency turnouts"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>General election constituency turnouts</span>".html_safe
  end
end
