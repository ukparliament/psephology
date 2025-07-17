class BoundarySetConstituencyAreaController < ApplicationController
  
  def index
    @boundary_set = get_boundary_set
    
    @constituency_areas = @boundary_set.constituency_areas
    
    @parent_boundary_set = @boundary_set.parent_boundary_set if @boundary_set.is_child_boundary_set?
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - constituency areas"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>Constituency areas</span>".html_safe
    @description = "Constituency areas established by the #{@boundary_set.display_title} boundary set."
    @crumb << { label: 'Boundary sets', url: boundary_set_list_url }
    @crumb << { label: @boundary_set.display_title, url: nil }
    @section = 'boundary-sets'
    @subsection = 'constituency-areas'
  end
end
