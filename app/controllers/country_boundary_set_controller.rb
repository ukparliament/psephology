require 'date'

class CountryBoundarySetController < ApplicationController
  
  def index
    country = params[:country]
    @country = Country.find_by_geographic_code( country )
    raise ActiveRecord::RecordNotFound unless @country
    @page_title = 'Boundary sets in ' + @country.name
  end
  
  def show
    country = params[:country]
    boundary_set = params[:boundary_set]
    boundary_set_date = Date.parse( boundary_set )
    @boundary_set = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name, li.title AS legislation_item_title
        FROM boundary_sets bs, countries c, legislation_items li
        WHERE start_on = '#{boundary_set_date}'
        AND bs.country_id = c.id
        AND c.geographic_code = '#{country}'
        AND li.id = bs.legislation_item_id
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @boundary_set
    
    # We get all the general elections held during the duration of the boundary set.
    @general_elections = @boundary_set.general_elections
    
    @constituency_areas = @boundary_set.constituency_areas
    @page_title = "Boundary set for #{@boundary_set.display_title} - constituency areas"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>Constituency areas</span>".html_safe
  end
end
