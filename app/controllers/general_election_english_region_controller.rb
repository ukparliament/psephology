class GeneralElectionEnglishRegionController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find_by_polling_on( general_election )
    raise ActiveRecord::RecordNotFound unless @general_election
    
    country = params[:country]
    @country = Country.find_by_geographic_code( country )
    raise ActiveRecord::RecordNotFound unless @country
    
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - English regions"
    
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>English regions</span>".html_safe
    @english_regions = EnglishRegion.all.where( "country_id = ?", @country.id ).order( 'name' )
  end
  
  def show
    general_election = params[:general_election]
    @general_election = GeneralElection.find_by_polling_on( general_election )
    raise ActiveRecord::RecordNotFound unless @general_election
    
    country = params[:country]
    @country = Country.find_by_geographic_code( country )
    raise ActiveRecord::RecordNotFound unless @country
    
    english_region = params[:english_region]
    @english_region = EnglishRegion.find_by_geographic_code( english_region )
    raise ActiveRecord::RecordNotFound unless @english_region
    
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England"
    

    
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England</span>".html_safe
    @elections = @general_election.elections_in_english_region( @english_region)
  end
end
