class GeneralElectionBoundarySetController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find_by_sql(
      "
        SELECT ge.*, pp.number AS parliament_period_number
        FROM general_elections ge, parliament_periods pp
        WHERE ge.parliament_period_id = pp.id
        AND ge.id = #{general_election}
        AND ge.is_notional IS FALSE
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @general_election
    
    @boundary_sets = @general_election.boundary_sets
    
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - boundary sets"
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Boundary sets</span>".html_safe
    @description = "Boundary sets in operation for the general election to the Parliament of the United Kingdom on #{@general_election.crumb_label}."
    @csv_url = general_election_boundary_set_list_url( :format => 'csv' )
    @crumb << { label: 'General elections', url: general_election_list_url }
    @crumb << { label: @general_election.crumb_label, url: general_election_party_list_url }
    @crumb << { label: 'Boundary sets', url: nil }
    @section = 'general-elections'
    @subsection = 'boundary-sets'
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"boundary-sets-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
      }
      format.html
    end
  end
end
