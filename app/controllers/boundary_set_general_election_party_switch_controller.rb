class BoundarySetGeneralElectionPartySwitchController < ApplicationController
  
  def index
    boundary_set = params[:boundary_set]
    
    @boundary_set = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, countries c
        WHERE bs.country_id = c.id
        AND bs.id = #{boundary_set}
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @boundary_set
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - Constituency party visualisation"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>Constituency party visualisation</span>".html_safe
    
    @nodes = @boundary_set.nodes
    @edges = @boundary_set.edges
    
    render layout: "d3"
  end
end
