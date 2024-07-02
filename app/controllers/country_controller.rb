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
    @section = 'boundary-sets'
    @description = 'Boundary sets establishing new constituencies, by country.'
    @crumb = "<li><a href='/boundary-sets'>Boundary sets</a></li>".html_safe
    @crumb += "<li>Countries</li>".html_safe
  end
  
  def show
    country = params[:country]
    @country = Country.find( country )
    @page_title = 
    @parent_country = @country.parent_country
    @child_countries = @country.child_countries
    @boundary_sets = @country.boundary_sets
    @page_title = "Boundary sets - #{@country.name}"
    @multiline_page_title = "Boundary sets <span class='subhead'>In #{@country.name}</span>".html_safe
    @section = 'boundary-sets'
    @description = "Boundary sets establishing new constituencies, in #{@country.name}."
    @crumb = "<li><a href='/boundary-sets'>Boundary sets</a></li>".html_safe
    @crumb += "<li>#{@country.name}</li>".html_safe
  end
end