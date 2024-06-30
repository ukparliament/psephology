class GeneralElectionEnglishRegionTurnoutController < ApplicationController
  
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
    
    country = params[:country]
    english_region = params[:english_region]
    @english_region = EnglishRegion.all.where( 'id = ?', english_region ).where( 'country_id =?', country).first
    
    raise ActiveRecord::RecordNotFound unless @general_election and @english_region
  
    @elections = @general_election.elections_by_turnout_in_english_region( @english_region )
    
    @section = 'general-elections'
    @subsection = 'turnouts'
    @crumb = "<li><a href='/general-elections'>General elections</a></li>"
    
    if @general_election.is_notional
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - by turnout"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - by turnout</span>".html_safe
      
      @description = ""
      @crumb += "<li><a href='/general-elections/#{@general_election.id}/political-parties'>#{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} (Notional)</a></li>"
      @crumb += "<li><a href='/general-elections/#{@general_election.id}/countries/2/political-parties'>England</a></li>"
      @crumb += "<li><a href='/general-elections/#{@general_election.id}/countries/2/english-regions/#{@english_region.id}/political-parties'>#{@english_region.name}</a></li>"
      @crumb += "<li>Turnouts</li>"
      
      render :template => 'general_election_english_region_turnout/index_notional'
    else
      @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - by turnout"
      @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - by turnout</span>".html_safe
      
      @description = ""
      @crumb += "<li><a href='/general-elections/#{@general_election.id}/political-parties'>#{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}</a></li>"
      @crumb += "<li><a href='/general-elections/#{@general_election.id}/countries/2/political-parties'>England</a></li>"
      @crumb += "<li><a href='/general-elections/#{@general_election.id}/countries/2/english-regions/#{@english_region.id}/political-parties'>#{@english_region.name}</a></li>"
      @crumb += "<li>Turnouts</li>"
    end
  end
end
