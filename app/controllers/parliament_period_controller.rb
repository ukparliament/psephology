class ParliamentPeriodController < ApplicationController
  
  def index
    @page_title = 'Parliament periods'
    @parliament_periods = ParliamentPeriod.all.order( 'summoned_on desc' )
  end
  
  def show
    parliament_period = params[:parliament_period]
    @parliament_period = ParliamentPeriod.find_by_number( parliament_period )
    raise ActiveRecord::RecordNotFound unless @parliament_period
    @page_title = "Parliament #{@parliament_period.number}"
    @general_election = @parliament_period.general_election
    @by_elections = @parliament_period.by_elections
  end
end
