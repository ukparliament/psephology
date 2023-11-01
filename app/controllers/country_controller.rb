class CountryController < ApplicationController
  
  def index
    @page_title = 'Countries'
    @countries = Country.all.order( 'name' )
  end
  
  def show
    country = params[:country]
    @country = Country.find_by_geographic_code( country )
    raise ActiveRecord::RecordNotFound unless @country
    @page_title = @country.name
  end
end
