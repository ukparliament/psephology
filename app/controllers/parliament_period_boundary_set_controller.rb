class ParliamentPeriodBoundarySetController < ApplicationController
  
  def index
    parliament_period = params[:parliament_period]
    @parliament_period = ParliamentPeriod.find_by_number( parliament_period )
    raise ActiveRecord::RecordNotFound unless @parliament_period
    
    @boundary_sets = @parliament_period.boundary_sets_for_general_elections
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"boundary-sets-parliament-#{@parliament_period.number}.csv\""
      }
      format.html {
        @page_title = "#{@parliament_period.number.ordinalize} Parliament of the United Kingdom - boundary sets"
        @multiline_page_title = "#{@parliament_period.number.ordinalize} Parliament of the United Kingdom <span class='subhead'>Boundary sets</span>".html_safe
        @description = "Boundary sets used in elections to the #{@parliament_period.number.ordinalize} Parliament of the United Kingdom."
        @csv_url = parliament_period_boundary_set_list_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_show_url }
        @crumb << { label: @parliament_period.crumb_label, url: parliament_period_show_url( :parliament_period => @parliament_period.number ) }
        @crumb << { label: 'Boundary sets', url: nil }
        @section = 'parliament-periods'
      }
    end
  end
end
