class GeneralElectionController < ApplicationController
  
  def index
    @general_elections = GeneralElection.find_by_sql(
      "
        SELECT ge.*, count(e.*) AS election_count, pp.number AS parliament_period_number, pp.summoned_on AS parliament_period_summoned_on, pp.dissolved_on AS parliament_period_dissolved_on
        FROM general_elections ge, elections e, parliament_periods pp
        WHERE e.general_election_id = ge.id
        AND ge.is_notional IS FALSE
        AND ge.parliament_period_id = pp.id
        GROUP BY ge.id, pp.id
        ORDER BY polling_on DESC
      "
    )
    @notional_general_elections = GeneralElection.find_by_sql(
      "
        SELECT ge.*, count(e.*) AS election_count, pp.number AS parliament_period_number, pp.summoned_on AS parliament_period_summoned_on, pp.dissolved_on AS parliament_period_dissolved_on
        FROM general_elections ge, elections e, parliament_periods pp
        WHERE e.general_election_id = ge.id
        AND ge.is_notional IS TRUE
        AND ge.parliament_period_id = pp.id
        GROUP BY ge.id, pp.id
        ORDER BY polling_on DESC
      "
    )
    
    @page_title = 'General elections'
    
    respond_to do |format|
      format.csv {
        @real_and_notional_general_elections = @general_elections.concat( @notional_general_elections )
      }
      format.html
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
    
    @countries = @general_election.top_level_countries_with_elections
    @elections = @general_election.elections
    
    if @general_election.is_notional
      
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - by constituency"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>By constituency</span>".html_safe
      
      render :template => 'general_election/show_notional'
    else
    
      @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - by constituency"
      @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>By constituency</span>".html_safe
    end
  end
end
