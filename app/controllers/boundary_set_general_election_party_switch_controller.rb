class BoundarySetGeneralElectionPartySwitchController < ApplicationController
  
  def index
    @boundary_set = get_boundary_set

    @page_title = "Boundary set for #{@boundary_set.display_title} - Constituency party visualisation"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>Constituency party visualisation</span>".html_safe
    
    @nodes = @boundary_set.nodes
    @edges = @boundary_set.edges
    
    render layout: "d3"
  end
end
