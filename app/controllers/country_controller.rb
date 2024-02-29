class CountryController < ApplicationController
  
  def index
    @page_title = 'Countries'
    @countries = Country.all.order( 'name' )
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