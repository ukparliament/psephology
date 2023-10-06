class GeneralElectionPartyController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find_by_polling_on( general_election )
    raise ActiveRecord::RecordNotFound unless @general_election
    
    @party_performances = @general_election.party_performance
    
    @page_title = "UK general election - #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - by party"
  end
end
