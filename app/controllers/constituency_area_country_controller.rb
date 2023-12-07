class ConstituencyAreaCountryController < ApplicationController
  
  def index
    @page_title = 'Current constituencies - countries'
    @multiline_page_title = "Current constituencies <span class='subhead'>Countries</span>".html_safe
    @current_countries = Country.find_by_sql(
      "
        SELECT c.*
        FROM countries c, constituency_areas ca, boundary_sets bs
        WHERE c.id = ca.country_id
        AND ca.boundary_set_id = bs.id
        AND bs.end_on IS NULL
        GROUP BY c.id
        ORDER BY c.name
      "
    )
  end
  
  def show
    country = params[:country]
    @country = Country.find( country )
    @page_title = "Current constituencies - #{@country.name}"
    @multiline_page_title = "Current constituencies <span class='subhead'>#{@country.name}</span>".html_safe
    @current_constituencies = @country.current_constituencies
  end
end
