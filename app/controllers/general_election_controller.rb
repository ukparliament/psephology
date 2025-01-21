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
    
    respond_to do |format|
      format.csv {
        @real_and_notional_general_elections = @general_elections.concat( @notional_general_elections )
      }
      format.html {
        @page_title = 'General elections'
        @description = 'General elections to the Parliament of the United Kingdom.'
        @csv_url = general_election_list_url( :format => 'csv' )
        @crumb << { label: 'General elections', url: nil }
        @section = 'general-elections'
      }
    end
  end
  
  def show
    @party_performances = @general_election.party_performance
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"parties-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
      }
      format.html {
        
        if @general_election.is_notional
          @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - by party"
          @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>By party</span>".html_safe
          @description = "Notional results for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listed by political party."
    
        else
          @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - by party"
          @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>By party</span>".html_safe
          @description = "Results for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listed by political party."
        end
        
        @csv_url = general_election_party_list_url( :format => 'csv' )
        @crumb << { label: 'General elections', url: general_election_list_url }
        @crumb << { label: @general_election.crumb_label, url: nil }
        @section = 'general-elections'
        @subsection = 'parties'
        
        if @general_election.is_notional
          render :template => 'general_election_party/index_notional'
        else
          render :template => 'general_election_party/index'
        end
      }
    end
  end
end
