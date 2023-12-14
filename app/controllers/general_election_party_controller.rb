class GeneralElectionPartyController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    
    @party_performances = @general_election.party_performance
    
    @uncertified_candidacies = @general_election.uncertified_candidacies
    
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - by party"
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>By party</span>".html_safe
  end
  
  def show
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@political_party.name}"
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@political_party.name}</span>".html_safe
  end
end
