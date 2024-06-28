class GeneralElectionCandidacyController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    
    respond_to do |format|
      format.csv {
        @candidacies = @general_election.candidacies
        response.headers['Content-Disposition'] = "attachment; filename=\"#{@general_election.csv_filename}\""
      }
      format.html {
        @section = 'general-elections'
        @csv_url = general_election_candidacy_list_url( :format => 'csv' )
        @description = ''
      }
    end
  end
end
