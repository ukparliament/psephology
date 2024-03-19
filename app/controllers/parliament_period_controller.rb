class ParliamentPeriodController < ApplicationController
  
  def index
    @page_title = 'Parliament periods'
    @parliament_periods = ParliamentPeriod.all.order( 'summoned_on desc' )
    expires_in 3.minutes, :public => true
  end
  
  def show
    parliament_period = params[:parliament_period]
    @parliament_period = ParliamentPeriod.find_by_number( parliament_period )
    raise ActiveRecord::RecordNotFound unless @parliament_period
    @page_title = "#{@parliament_period.number.ordinalize} Parliament of the United Kingdom"
    @general_elections = @parliament_period.general_elections
    @boundary_sets = @parliament_period.boundary_sets
    @by_elections = @parliament_period.by_elections
    expires_in 3.minutes, :public => true
  end
end
