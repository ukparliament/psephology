class BoundarySetController < ApplicationController
  
  def index
    @boundary_sets = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name, c.geography_code AS country_geography_code
        FROM boundary_sets bs, countries c
        WHERE bs.country_id = c.id
        ORDER BY start_on, country_name
      "
    )
    @page_title = "Boundary sets"
  end
end
