class CountryBoundaryPartySwitchController < ApplicationController
  
  def index
    country = params[:country]
    boundary_set = params[:boundary_set]
    
    @boundary_set = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name, li.title as legislation_item_title
        FROM boundary_sets bs, countries c, legislation_items li
        WHERE bs.country_id = c.id
        AND c.geographic_code = '#{country}'
        AND bs.start_on = '#{boundary_set}'
        AND bs.legislation_item_id = li.id
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @boundary_set
    
    # We get all the general elections held during the duration of the boundary set.
    @general_elections = @boundary_set.general_elections
    
    @page_title = "Boundary set for #{@boundary_set.country_name} (#{@boundary_set.display_dates}) - party switches"
    
    @nodes = @boundary_set.nodes
    @edges = @boundary_set.edges
    
    render layout: "d3"
  end
end
