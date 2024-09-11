class CountryController < ApplicationController
  
  def index
    @countries = Country.find_by_sql(
      "
        SELECT c.*
        FROM countries c
        WHERE parent_country_id IS NULL
        ORDER BY c.name
      "
    )
    
    @page_title = 'Boundary sets - by country'
    @multiline_page_title = "Boundary sets <span class='subhead'>By country</span>".html_safe
    @description = 'Boundary sets establishing new constituencies, by country.'
    @crumb << { label: 'Boundary sets', url: boundary_set_list_url }
    @crumb << { label: 'Countries', url: nil }
    @section = 'boundary-sets'
  end
  
  def show
    country = params[:country]
    @country = Country.find( country )
    @parent_country = @country.parent_country
    @child_countries = @country.child_countries
    @boundary_sets = @country.boundary_sets
    
    @page_title = "Boundary sets - #{@country.name}"
    @multiline_page_title = "Boundary sets <span class='subhead'>In #{@country.name}</span>".html_safe
    @description = "Boundary sets establishing new constituencies, in #{@country.name}."
    @crumb << { label: 'Boundary sets', url: boundary_set_list_url }
    @crumb << { label: @country.name, url: nil }
    @section = 'boundary-sets'
  end
end