class GeneralElectionCountryUncertifiedCandidacyController < ApplicationController
  
  def index
    country = params[:country]
    @country = Country.find( country )
    @uncertified_candidacies = @general_election.uncertified_candidacies_in_country( @country )
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"non-party-candidates-in-#{@country.name.downcase.gsub( ' ', '-')}-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
        render :template => 'general_election_uncertified_candidacy/index'
      }
      format.html {
        @page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - non-party candidates"
        @multiline_page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - non-party candidates</span>".html_safe
        @description = "Non-party candidates in #{@country.name} for #{@general_election.noun_phrase_article} general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
        @csv_url = general_election_country_uncertified_candidacy_list_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: @country.name, url: general_election_country_show_url }
        @crumb << { label: 'Non-party candidates', url: nil }
        @section = 'elections'
        @subsection = 'uncertified-candidacies'
      }
    end
  end
end
