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
    
    @section = 'boundary-sets'
    @subsection = 'vote-shares'
    @description = "Vote shares of winning candidates in general elections during the existence of the #{@boundary_set.display_title} boundary set."
    @crumb = "<li><a href='/boundary-sets'>Boundary sets</a></li>"
    @crumb += "<li><a href='/boundary-sets/#{@boundary_set.id}'>" + @boundary_set.display_title + '</a></li>'
    @crumb += '<li>Vote shares</li>'
  end
end
