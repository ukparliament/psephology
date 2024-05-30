class GeneralElectionMapController < ApplicationController
  
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
    
    @elections = @general_election.elections
    
    if @general_election.is_notional
      
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - map"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Map</span>".html_safe
      
      render :template => 'general_election_map/index_notional'
    
    else
    
      @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - map"
      @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Map</span>".html_safe
    end
  end
end
