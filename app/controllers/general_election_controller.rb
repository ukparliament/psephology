class GeneralElectionController < ApplicationController
  
  def index
    @general_elections = GeneralElection.all.order( 'polling_on desc' )
    @page_title = 'General elections'
  end
  
  def show
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - by area"
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>By area</span>".html_safe
    @countries = @general_election.countries
    @elections = @general_election.elections
  end
end
