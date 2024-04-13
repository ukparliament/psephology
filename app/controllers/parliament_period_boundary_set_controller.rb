class ParliamentPeriodBoundarySetController < ApplicationController
  
  def index
    parliament_period = params[:parliament_period]
    @parliament_period = ParliamentPeriod.find_by_number( parliament_period )
    raise ActiveRecord::RecordNotFound unless @parliament_period
    @page_title = "#{@parliament_period.number.ordinalize} Parliament of the United Kingdom - boundary sets"
    @multiline_page_title = "#{@parliament_period.number.ordinalize} Parliament of the United Kingdom <span class='subhead'>Boundary sets</span>".html_safe
    @boundary_sets = @parliament_period.boundary_sets
  end
end
