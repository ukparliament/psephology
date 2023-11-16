class BoundarySetGeneralElectionController < ApplicationController
  
  def index
    boundary_set = params[:boundary_set]
    
    @boundary_set = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name, li.title AS legislation_item_title
        FROM boundary_sets bs, legislation_items li, countries c
        WHERE bs.legislation_item_id = li.id
        AND bs.country_id = c.id
        AND bs.id = #{boundary_set}
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @boundary_set
    
    @general_elections = @boundary_set.general_elections
    @page_title = "Boundary set for #{@boundary_set.display_title} - general elections"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>General elections</span>".html_safe
  end
end
