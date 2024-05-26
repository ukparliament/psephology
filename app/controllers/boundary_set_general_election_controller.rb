class BoundarySetGeneralElectionController < ApplicationController
  
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
    
    @general_elections = @boundary_set.general_elections_with_ordinality
    @page_title = "Boundary set for #{@boundary_set.display_title} - general elections"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>General elections</span>".html_safe
  end
end
