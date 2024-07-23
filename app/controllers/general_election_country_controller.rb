class GeneralElectionCountryController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    
    @countries = @general_election.top_level_countries_with_elections
    
    @crumb << { label: 'General elections', url: general_election_list_url }
    @crumb << { label: @general_election.crumb_label, url: general_election_party_list_url }
    @crumb << { label: 'Countries', url: nil }
    @section = 'general-elections'
    
    if @general_election.is_notional
      
      @page_title = "Notional results for a UK general election on  #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Countries"
      @multiline_page_title = "Notional results for a UK general election on  #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Countries</span>".html_safe
      @description = "Notional results for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by country."
      
      render :template => 'general_election_country/index_notional'
    else
      @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Countries"
      @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Countries</span>".html_safe
      @description = "Results for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by country."
    end
  end
  
  def show
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
    
    @countries = @general_election.child_countries_with_elections_in_country( @country )
    @english_regions = @general_election.english_regions_in_country( @country )
    @elections = @general_election.elections_in_country( @country)
    
    @crumb << { label: 'General elections', url: general_election_list_url }
    @crumb << { label: @general_election.crumb_label, url: general_election_party_list_url }
    @crumb << { label: @country.name, url: general_election_country_political_party_list_url }
    @crumb << { label: 'Constituencies', url: nil }
    @section = 'general-elections'
    @subsection = 'constituency-areas'
    
    if @general_election.is_notional
      @page_title = "Notional results for a UK general election on  #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - by constituency"
      @multiline_page_title = "Notional results for a UK general election on  #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - by constituency</span>".html_safe
      @description = "Notional results for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by constituencies in #{@country.name}."
      
      
      render :template => 'general_election_country/show_notional'
    else
      @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - by constituency"
      @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - by constituency</span>".html_safe
      @description = "Results for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by constituencies in #{@country.name}."
    end
  end
end
