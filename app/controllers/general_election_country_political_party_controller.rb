class GeneralElectionCountryPoliticalPartyController < ApplicationController
  
  def index
    country = params[:country]
    @country = Country.find( country )
    @party_performances = @general_election.party_performance_in_country( @country )
    @valid_vote_count_in_general_election_in_country = @general_election.valid_vote_count_in_country( @country )
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"parties-in-#{@country.name.downcase.gsub( ' ', '-' )}-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
        render :template => 'general_election_party/index'
      }
      format.html{
        @page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - by party"
        @multiline_page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - by party</span>".html_safe
        @description = "#{@general_election.result_type} in #{@country.name} for #{@general_election.noun_phrase_article} general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by political party."
        @csv_url = general_election_country_political_party_list_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: @country.name, url: general_election_country_show_url }
        @crumb << { label: 'Political parties', url: nil }
        @section = 'elections'
        @subsection = 'parties'
        
        render :template => 'general_election_country_political_party/index_notional' if @general_election.is_notional
      }
    end
  end
  
  def show
    country = params[:country]
    @country = Country.find( country )
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    
    @page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - #{@political_party.name}"
    @multiline_page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - #{@political_party.name}</span>".html_safe
    @description = "#{@general_election.result_type} in #{@country.name} for #{@general_election.noun_phrase_article} general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@political_party.name}."
    @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
    @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
    @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
    @crumb << { label: @country.name, url: general_election_country_show_url }
    @crumb << { label: @political_party.name, url: nil }
    @section = 'elections'
    
    render :template => 'general_election_country_political_party/show_notional' if @general_election.is_notional
  end
end
