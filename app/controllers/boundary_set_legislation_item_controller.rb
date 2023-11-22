class BoundarySetLegislationItemController < ApplicationController
  
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
    
    # We get all the general elections held during the duration of the boundary set.
    @general_elections = @boundary_set.general_elections
    
    # We get the establishing legislation for the boundary set.
    @establishing_legislation = @boundary_set.establishing_legislation
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - establishing legislation"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>Establishing legislation</span>".html_safe
  end
end