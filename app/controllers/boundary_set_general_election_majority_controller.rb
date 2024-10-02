class BoundarySetGeneralElectionMajorityController < ApplicationController

  # This controller is now badly named, also including by-elections.
  
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
    
    # We get all elections held in a constituency area defined by the boundary set, to include by-elections.
    @elections = @boundary_set.all_elections
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - majorities"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>Majorities</span>".html_safe
    @description = "Majorities of winning candidates in elections during the existence of the #{@boundary_set.display_title} boundary set."
    @crumb << { label: 'Boundary sets', url: boundary_set_list_url }
    @crumb << { label: @boundary_set.display_title, url: boundary_set_show_url( :boundary_set => @boundary_set ) }
    @crumb << { label: 'Majorities', url: nil }
    @section = 'boundary-sets'
    @subsection = 'majorities'
  end
end
