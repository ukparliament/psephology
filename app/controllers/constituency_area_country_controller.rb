class ConstituencyAreaCountryController < ApplicationController
  
  def index
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
    
    @page_title = 'Current constituencies - countries'
    @multiline_page_title = "Current constituencies <span class='subhead'>Countries</span>".html_safe
    @description = "Current constituency areas in the United Kingdom, by country."
    @crumb = "<li><a href='/constituency-areas/current'>Constituency areas</a></li>"
    @crumb += "<li>Countries</li>"
    @section = 'constituency-areas'
  end
  
  def show
    country = params[:country]
    @country = Country.find( country )
    @english_regions = @country.current_english_regions
    @current_constituencies = @country.current_constituencies
    

    @page_title = "Current constituencies - #{@country.name}"
    @multiline_page_title = "Current constituencies <span class='subhead'>#{@country.name}</span>".html_safe
    @description = "Current constituency areas in #{@country.name}."
    @crumb = "<li><a href='/constituency-areas/current'>Constituency areas</a></li>"
    @crumb += "<li>#{@country.name}</li>"
    @section = 'constituency-areas'
  end
end
