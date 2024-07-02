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
        @crumb = "<li><a href='/general-elections'>General elections</a></li>"
        @crumb += "<li><a href='/general-elections/#{@general_election.id}/political-parties'>#{@general_election.crumb_label}</a></li>"
        @crumb += "<li>Candidates</li>"
        if @general_election.is_notional
          @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - candidates"
          @description = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listing all candidates, available as a CSV."
        else
          @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - candidates"
          @description = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listing all candidates, available as a CSV."
        end
        
        @csv_url = general_election_candidacy_list_url( :format => 'csv' )
        @section = 'general-elections'
      }
    end
  end
end
