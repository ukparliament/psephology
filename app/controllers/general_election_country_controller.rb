class GeneralElectionCountryController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Countries"
    
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Countries</span>".html_safe
    @countries = @general_election.top_level_countries_with_elections
    
    if @general_election.is_notional
      
      @page_title = "Notional results for a UK general election on  #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Countries"
    
      @multiline_page_title = "Notional results for a UK general election on  #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Countries</span>".html_safe
      
      render :template => 'general_election_country/index_notional'
    else
    
      @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Countries"
    
      @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Countries</span>".html_safe
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
    
    if @general_election.is_notional
      
      @page_title = "Notional results for a UK general election on  #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - by constituency"
    
      @multiline_page_title = "Notional results for a UK general election on  #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - by constituency</span>".html_safe
      
      render :template => 'general_election_country/show_notional'
    else
    
      @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - by constituency"
    
      @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - by constituency</span>".html_safe
    end
  end
end
