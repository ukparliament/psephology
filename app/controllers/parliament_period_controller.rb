class ParliamentPeriodController < ApplicationController
  
  def index
    @page_title = 'Parliament periods'
    @parliament_periods = ParliamentPeriod.all.order( 'summoned_on desc' )
  end
  
  def show
    parliament_period = params[:parliament_period]
    @parliament_period = ParliamentPeriod.find( parliament_period )
    @page_title = "Parliament #{@parliament_period.number}"
  end
end
