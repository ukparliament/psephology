class ParliamentPeriodBoundarySetController < ApplicationController
  
  def index
    parliament_period = params[:parliament_period]
    @parliament_period = ParliamentPeriod.find_by_number( parliament_period )
    raise ActiveRecord::RecordNotFound unless @parliament_period
    @page_title = "#{@parliament_period.number.ordinalize} Parliament of the United Kingdom - boundary sets"
    @multiline_page_title = "#{@parliament_period.number.ordinalize} Parliament of the United Kingdom <span class='subhead'>Boundary sets</span>".html_safe
    @boundary_sets = @parliament_period.boundary_sets_for_general_elections
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"boundary-sets-parliament-#{@parliament_period.number}.csv\""
      }
      format.html
    end
  end
end
