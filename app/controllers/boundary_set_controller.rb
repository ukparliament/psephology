class BoundarySetController < ApplicationController
  
  def index
    @boundary_sets = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, countries c
        WHERE bs.country_id = c.id
        ORDER BY start_on, country_name
      "
    )
    @page_title = "Boundary sets"
  end
  
  def show
    boundary_set = params[:boundary_set]
    puts boundary_set
    @boundary_set = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name, oic.title AS order_in_council_title, oic.uri AS order_in_council_uri
        FROM boundary_sets bs, countries c, orders_in_council oic
        WHERE bs.id = #{boundary_set}
        AND bs.country_id = c.id
        AND bs.order_in_council_id = oic.id
      "
    ).first
    @constituency_areas = @boundary_set.constituency_areas
    @page_title = "Boundary set for #{@boundary_set.display_title}"
  end
end
