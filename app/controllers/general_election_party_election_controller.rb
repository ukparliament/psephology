class GeneralElectionPartyElectionController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Elections contested by #{@political_party.name}"
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Elections contested by #{@political_party.name}</span>".html_safe
    
    @elections_contested = @political_party.elections_contested_in_general_election( @general_election )
  end
  
  def won
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Elections won by #{@political_party.name}"
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Elections won by #{@political_party.name}</span>".html_safe
    
    @elections_won = @political_party.elections_won_in_general_election( @general_election )
  end
end
