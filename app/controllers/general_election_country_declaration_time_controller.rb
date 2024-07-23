class GeneralElectionCountryDeclarationTimeController < ApplicationController
  
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
    
    @elections = @general_election.elections_by_declaration_time_in_country( @country )
    
    @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - by declaration time"
    @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - by declaration time</span>".html_safe
    @description = "Results in #{@country.name} for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by declaration time."
    @csv_url = general_election_country_declaration_time_list_url( :format => 'csv' )
    @crumb << { label: 'General elections', url: general_election_list_url }
    @crumb << { label: @general_election.crumb_label, url: general_election_party_list_url }
    @crumb << { label: @country.name, url: general_election_country_political_party_list_url }
    @crumb << { label: 'Declaration times', url: nil }
    @section = 'general-elections'
    @subsection = 'declaration-times'
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"declaration-times-in-#{@country.name.downcase.gsub( ' ', '-')}-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
        render :template => 'general_election_declaration_times/index'
      }
      format.html{
      }
    end
  end
end
