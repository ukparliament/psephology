require 'date'

class CountryBoundarySetController < ApplicationController
  
  def index
    country = params[:country]
    @country = Country.find_by_geographic_code( country )
    raise ActiveRecord::RecordNotFound unless @country
    @page_title = @country.name + ' - boundary sets'
  end
  
  def show
    country = params[:country]
    boundary_set = params[:boundary_set]
    boundary_set_date = Date.parse( boundary_set )
    @boundary_set = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name, oic.title AS order_in_council_title
        FROM boundary_sets bs, countries c, orders_in_council oic
        WHERE start_on = '#{boundary_set_date}'
        AND bs.country_id = c.id
        AND c.geographic_code = '#{country}'
        AND oic.id = bs.order_in_council_id
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @boundary_set
    @constituency_areas = @boundary_set.constituency_areas
    @page_title = "Boundary set for #{@boundary_set.display_title}"
  end
end
