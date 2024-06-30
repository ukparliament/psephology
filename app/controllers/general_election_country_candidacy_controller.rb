class GeneralElectionCountryCandidacyController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    
    country = params[:country]
    @country = Country.find( country )
    
    respond_to do |format|
      format.csv {
        @candidacies = @general_election.candidacies_in_country( @country )
        response.headers['Content-Disposition'] = "attachment; filename=\"#{@general_election.csv_filename_for_country( @country)}\""
        render :template => 'general_election_candidacy/index'
      }
      format.html {
        @section = 'general-elections'
        @csv_url = general_election_country_candidacy_list_url( :format => 'csv' )
        @description = 'beep-bop'
      }
    end
  end
end
