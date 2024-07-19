class BoundarySetGeneralElectionVoteShareController < ApplicationController
  
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
    
    # We get all elections held in a constituency area defined by the boundary set.
    @elections = @boundary_set.elections_in_general_elections
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - general election vote share"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>General elections by vote share of winning candidate</span>".html_safe
    @description = "Vote shares of winning candidates in general elections during the existence of the #{@boundary_set.display_title} boundary set."
    @crumb << { label: 'Boundary sets', url: boundary_set_list_url }
    @crumb << { label: @boundary_set.display_title, url: boundary_set_show_url( :boundary_set => @boundary_set ) }
    @crumb << { label: 'Vote shares', url: nil }
    @section = 'boundary-sets'
    @subsection = 'vote-shares'
  end
end
