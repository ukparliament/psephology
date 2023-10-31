class CountryBoundaryPartySwitchController < ApplicationController
  
  def index
    country = params[:country]
    boundary_set = params[:boundary_set]
    
    @boundary_set = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, countries c
        WHERE bs.country_id = c.id
        AND c.geography_code = '#{country}'
        AND bs.start_on = '#{boundary_set}'
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @boundary_set
    
    @page_title = "Boundary set for #{@boundary_set.country_name} (#{@boundary_set.display_dates}) - party switches"
    
    @nodes = @boundary_set.nodes
    @edges = @boundary_set.edges
    
    render layout: "d3"
  end
end
