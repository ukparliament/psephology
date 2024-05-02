class GeneralElectionCandidacyController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    
    respond_to do |format|
      format.csv {
        @candidacies = @general_election.candidacies
        response.headers['Content-Disposition'] = "attachment; filename=\"#{@general_election.csv_filename}\""
      }
      format.html
    end
  end
end
