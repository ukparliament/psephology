class BoundarySetLegislationItemController < ApplicationController
  
  def index
    @boundary_set = get_boundary_set
    
    @parent_boundary_set = @boundary_set.parent_boundary_set if @boundary_set.is_child_boundary_set?

    # We get the establishing legislation for the boundary set.
    @establishing_legislation = @boundary_set.establishing_legislation
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - establishing legislation"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>Establishing legislation</span>".html_safe
    @description = "Legislation establishing the #{@boundary_set.display_title} boundary set."
    @crumb << { label: 'Boundary sets', url: boundary_set_list_url }
    @crumb << { label: @boundary_set.display_title, url: boundary_set_show_url( :boundary_set => @boundary_set ) }
    @crumb << { label: 'Establishing legislation', url: nil }
    @section = 'boundary-sets'
    @subsection = 'establishing-legislation'
  end
end
