class GeneralElectionCandidacyController < ApplicationController
  
  def index
    
    respond_to do |format|
      format.csv {
        @candidacies = @general_election.candidacies
        response.headers['Content-Disposition'] = "attachment; filename=\"#{@general_election.csv_filename}\""
      }
      format.html {
        @page_title = "#{@general_election.result_type} for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - candidates"
        @description = "#{@general_election.result_type} for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listing all candidates, available as a CSV."
        @csv_url = general_election_candidacy_list_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: 'Candidates', url: nil }
        @section = 'elections'
      }
    end
  end
end
