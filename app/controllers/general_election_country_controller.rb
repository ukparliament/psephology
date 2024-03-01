class GeneralElectionCountryController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Countries"
    
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Countries</span>".html_safe
    @countries = @general_election.top_level_countries_with_elections
  end
  
  def show
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    
    country = params[:country]
    @country = Country.find( country )
    
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name}"
    
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name}</span>".html_safe
    @countries = @general_election.child_countries_with_elections_in_country( @country )
    @english_regions = @general_election.english_regions_in_country( @country )
    @elections = @general_election.elections_in_country( @country)
  end
end
