class GeneralElectionCountryController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find_by_polling_on( general_election )
    raise ActiveRecord::RecordNotFound unless @general_election
    
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Countries"
    
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Countries</span>".html_safe
    @countries = Country.all.order( 'name' )
  end
  
  def show
    general_election = params[:general_election]
    @general_election = GeneralElection.find_by_polling_on( general_election )
    raise ActiveRecord::RecordNotFound unless @general_election
    
    country = params[:country]
    @country = Country.find_by_geographic_code( country )
    raise ActiveRecord::RecordNotFound unless @country
    
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name}"
    
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name}</span>".html_safe
    @english_regions = EnglishRegion.all.where( "country_id = ?", @country.id ).order( 'name' )
    @elections = @general_election.elections_in_country( @country)
  end
end
