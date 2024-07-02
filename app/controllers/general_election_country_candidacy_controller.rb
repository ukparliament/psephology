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
        @crumb = "<li><a href='/general-elections'>General elections</a></li>"
        
        @crumb = "<li><a href='/general-elections'>General elections</a></li>"
        if @general_election.is_notional
          @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - candidates"
          @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - candidates</span>".html_safe
          @description = "Notional results in #{@country.name} for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listing all candidates, available as a CSV."
          @crumb += "<li><a href='/general-elections/#{@general_election.id}/political-parties'>#{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} (Notional)</a></li>"
          @crumb += "<li><a href='/general-elections/#{@general_election.id}/countries/#{@country.id}/political-parties'>#{@country.name}</a></li>"
          @crumb += "<li>Candidates</li>"
        else
          @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - candidates"
          @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - candidates</span>".html_safe
          @description = "Results in #{@country.name} for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listing all candidates, available as a CSV."
          @crumb += "<li><a href='/general-elections/#{@general_election.id}/political-parties'>#{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}</a></li>"
          @crumb += "<li><a href='/general-elections/#{@general_election.id}/countries/#{@country.id}/political-parties'>#{@country.name}</a></li>"
          @crumb += "<li>Candidates</li>"
        end
        
        @csv_url = general_election_candidacy_list_url( :format => 'csv' )
        @section = 'general-elections'
      }
    end
  end
end
