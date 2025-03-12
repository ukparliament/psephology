class BoundarySetGeneralElectionTurnoutController < ApplicationController

  # This controller is now badly named, also including by-elections.
  
  def index
    @boundary_set = get_boundary_set

    # We get all elections held in a constituency area defined by the boundary set, to include by-elections.
    @elections = @boundary_set.all_elections
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - turnouts"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>Turnouts</span>".html_safe
    @description = "Turnouts in elections in #{@boundary_set.country_name} held during the existence of the #{@boundary_set.display_title} boundary set."
    @crumb << { label: 'Boundary sets', url: boundary_set_list_url }
    @crumb << { label: @boundary_set.display_title, url: boundary_set_show_url( :boundary_set => @boundary_set ) }
    @crumb << { label: 'Turnouts', url: nil }
    @section = 'boundary-sets'
    @subsection = 'turnouts'
  end
end
