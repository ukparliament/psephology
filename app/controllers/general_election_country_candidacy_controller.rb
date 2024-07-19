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
        @csv_url = general_election_country_candidacy_list_url( :format => 'csv' )
        @crumb << { label: 'General elections', url: general_election_list_url }
        @crumb << { label: @general_election.crumb_label, url: general_election_party_list_url }
        @crumb << { label: @country.name, url: general_election_country_political_party_list_url }
        @crumb << { label: 'Candidates', url: nil }
        @section = 'general-elections'
        
        if @general_election.is_notional
          @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - candidates"
          @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - candidates</span>".html_safe
          @description = "Notional results in #{@country.name} for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listing all candidates, available as a CSV."
        else
          @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - candidates"
          @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - candidates</span>".html_safe
          @description = "Results in #{@country.name} for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listing all candidates, available as a CSV."
        end
      }
    end
  end
end
