class GeneralElectionEnglishRegionController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    country = params[:country]
    @country = Country.find( country )
    @page_title = "UK general election - #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - English regions"
    @english_regions = EnglishRegion.all.where( "country_id = ?", @country.id ).order( 'name' )
  end
  
  def show
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    country = params[:country]
    @country = Country.find( country )
    english_region = params[:english_region]
    @english_region = EnglishRegion.find( english_region )
    @page_title = "UK general election - #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England"
    @elections = @general_election.elections_in_english_region( @english_region)
  end
end
