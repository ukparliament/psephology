class ParliamentPeriodController < ApplicationController
  
  def index
    @parliament_periods = ParliamentPeriod.all.order( 'summoned_on desc' )
    
    @page_title = 'Parliament periods'
    @description = 'Parliaments of the United Kingdom since 1801'
    @csv_url = parliament_period_list_url( :format => 'csv' )
    @crumb << { label: 'Parliament periods', url: nil }
    @section = 'parliament-periods'
  end
  
  def show
    parliament_period = params[:parliament_period]
    @parliament_period = ParliamentPeriod.find_by_number( parliament_period )
    raise ActiveRecord::RecordNotFound unless @parliament_period
    
    @general_election = @parliament_period.general_election
    @by_elections = @parliament_period.by_elections
    @boundary_sets = @parliament_period.boundary_sets_for_general_elections
    
    @page_title = "#{@parliament_period.number.ordinalize} Parliament of the United Kingdom"
    @description = "The #{@parliament_period.number.ordinalize} Parliament of the United Kingdom."
    @crumb << { label: 'Parliament periods', url: parliament_period_show_url }
    @crumb << { label: "#{@parliament_period.number.ordinalize} Parliament", url: nil }
    @section = 'parliament-periods'
  end
end
