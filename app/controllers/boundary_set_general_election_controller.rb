class BoundarySetGeneralElectionController < ApplicationController
  
  def index
    @boundary_set = get_boundary_set
    
    @general_elections = @boundary_set.general_elections_with_ordinality
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - general elections"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>General elections</span>".html_safe
    @description = "General elections held during the existence of the #{@boundary_set.display_title} boundary set."
    @crumb << { label: 'Boundary sets', url: boundary_set_list_url }
    @crumb << { label: @boundary_set.display_title, url: boundary_set_show_url( :boundary_set => @boundary_set ) }
    @crumb << { label: 'General elections', url: nil }
    @section = 'boundary-sets'
    @subsection = 'general-elections'
  end
end
