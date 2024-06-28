class ParliamentPeriodController < ApplicationController
  
  def index
    @page_title = 'Parliament periods'
    @parliament_periods = ParliamentPeriod.all.order( 'summoned_on desc' )
    
    @section = 'parliament-periods'
    @description = 'Parliaments of the United Kingdom since 1801'
    @csv_url = parliament_period_list_url( :format => 'csv' )
    @crumb = "<li>Parliament periods</li>".html_safe
  end
  
  def show
    parliament_period = params[:parliament_period]
    @parliament_period = ParliamentPeriod.find_by_number( parliament_period )
    raise ActiveRecord::RecordNotFound unless @parliament_period
    @page_title = "#{@parliament_period.number.ordinalize} Parliament of the United Kingdom"
    @general_elections = @parliament_period.general_elections
    @boundary_sets = @parliament_period.boundary_sets_for_general_elections
    @by_elections = @parliament_period.by_elections
    
    @section = 'parliament-periods'
    @description = "The #{@parliament_period.number.ordinalize} Parliament of the United Kingdom."
    @crumb = "<li><a href='/parliament-periods'>Parliament periods</a></li>"
    @crumb += "<li>#{@parliament_period.number.ordinalize} Parliament</li>"
  end
end
