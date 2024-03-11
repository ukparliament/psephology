class GeneralElectionController < ApplicationController
  
  def index
    @general_elections = GeneralElection.find_by_sql(
      "
        SELECT ge.*, count(e.*) AS election_count
        FROM general_elections ge, elections e
        WHERE e.general_election_id = ge.id
        GROUP BY ge.id
        ORDER BY polling_on DESC
      "
    )
    @page_title = 'General elections'
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
    
    if @general_election.is_notional
      
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - by area"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>By area</span>".html_safe
    else
    
      @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - by area"
      @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>By area</span>".html_safe
    end
    
    @countries = @general_election.top_level_countries_with_elections
    @elections = @general_election.elections
  end
end
