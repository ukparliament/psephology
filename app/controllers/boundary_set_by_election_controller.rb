class BoundarySetByElectionController < ApplicationController
  
  def index
    @boundary_set = get_boundary_set
    
    @by_elections = @boundary_set.by_elections
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - by-elections"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>By-elections</span>".html_safe
    @description = "By-elections held during the existence of the #{@boundary_set.display_title} boundary set."
    @crumb << { label: 'Boundary sets', url: boundary_set_list_url }
    @crumb << { label: @boundary_set.display_title, url: boundary_set_show_url( :boundary_set => @boundary_set ) }
    @crumb << { label: 'By-elections', url: nil }
    @section = 'boundary-sets'
    @subsection = 'by-elections'
  end
end
