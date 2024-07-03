class GeneralElectionCountryTurnoutController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find_by_sql(
      "
        SELECT ge.*, pp.number AS parliament_period_number
        FROM general_elections ge, parliament_periods pp
        WHERE ge.parliament_period_id = pp.id
        AND ge.id = #{general_election}
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @general_election
    
    country = params[:country]
    @country = Country.find( country )
    
    @elections = @general_election.elections_by_turnout_in_country( @country )
    
    @csv_url = general_election_country_turnout_list_url( :format => 'csv' )
    @crumb = "<li><a href='/general-elections'>General elections</a></li>"
    @crumb += "<li><a href='/general-elections/#{@general_election.id}/political-parties'>#{@general_election.crumb_label}</a></li>"
    @crumb += "<li><a href='/general-elections/#{@general_election.id}/countries/#{@country.id}/political-parties'>#{@country.name}</a></li>"
    @crumb += "<li>Turnouts</li>"
    @section = 'general-elections'
    @subsection = 'turnouts'
    
    if @general_election.is_notional
      
      @page_title = "Notional results for a UK general election on  #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - by turnout"
    
      @multiline_page_title = "Notional results for a UK general election on  #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - by turnout</span>".html_safe
      
      @description = "Notional results in #{@country.name} for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by turnout."
    else
    
      @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - by turnout"
    
      @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - by turnout</span>".html_safe
      
      @description = "Results in #{@country.name} for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by turnout."
    end
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"turnout-in-#{@country.name.downcase.gsub( ' ', '-' )}-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
        render :template => 'general_election_turnout/index'
      }
      format.html{
        render :template => 'general_election_country_turnout/index_notional' if @general_election.is_notional
      }
    end
  end
end
