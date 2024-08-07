class GeneralElectionCountryElectionController < ApplicationController
  
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
    
    @elections = @general_election.elections_in_country( @country)
    
    @csv_url = general_election_country_election_list_url( :format => 'csv' )
    @crumb << { label: 'General elections', url: general_election_list_url }
    @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
    @crumb << { label: @country.name, url: general_election_country_show_url }
    @crumb << { label: 'Elections', url: nil }
    @section = 'general-elections'
    
    if @general_election.is_notional
      @page_title = "Notional results for a UK general election on  #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Elections in #{@country.name}"
      @multiline_page_title = "Notional results for a UK general election on  #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Elections in #{@country.name}</span>".html_safe
      @description = "Notional results in #{@country.name} for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listing all elections."
    else
      @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Elections in #{@country.name}"
      @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Elections in #{@country.name}</span>".html_safe
      @description = "Results in #{@country.name} for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listing all elections."
    end

    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"elections-in-#{@country.name.downcase.gsub( ' ', '-' )}-in-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
        render :template => 'general_election_election/index'
      }
      format.html{
        render :template => 'general_election_election/index_notional' if @general_election.is_notional
      }
    end
  end
end
