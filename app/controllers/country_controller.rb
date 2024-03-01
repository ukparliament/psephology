class CountryController < ApplicationController
  
  def index
    @page_title = 'Countries'
    @countries = Country.find_by_sql(
      "
        SELECT c.*
        FROM countries c
        WHERE parent_country_id IS NULL
        ORDER BY c.name
      "
    )
  end
  
  def show
    country = params[:country]
    @country = Country.find( country )
    @page_title = @country.name
    @parent_country = @country.parent_country
    @child_countries = @country.child_countries
    @boundary_sets = @country.boundary_sets
  end
end