class GeneralElectionBoundarySetController < ApplicationController
  
  def index
    @boundary_sets = @general_election.boundary_sets
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"boundary-sets-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
      }
      format.html {
        @page_title = "#{@general_election.common_title} - boundary sets"
        @multiline_page_title = "#{@general_election.common_title} <span class='subhead'>Boundary sets</span>".html_safe
        @description = "#{@general_election.common_description} listing boundary sets in operation."
        @csv_url = general_election_boundary_set_list_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: 'Boundary sets', url: nil }
        @section = 'elections'
        @subsection = 'boundary-sets'
      }
    end
  end
end
