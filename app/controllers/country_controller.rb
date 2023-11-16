class CountryController < ApplicationController
  
  def index
    @page_title = 'Countries'
    @countries = Country.all.order( 'name' )
  end
  
  def show
    country = params[:country]
    @country = Country.find( country )
    @page_title = @country.name
  end
end
