class ParliamentPeriodByElectionController < ApplicationController

  def index
    parliament_period = params[:parliament_period]
    @parliament_period = ParliamentPeriod.find_by_number( parliament_period )
    raise ActiveRecord::RecordNotFound unless @parliament_period
    
    @by_elections = @parliament_period.by_elections
    
    @page_title = "#{@parliament_period.number.ordinalize} Parliament of the United Kingdom - by-elections"
    @multiline_page_title = "#{@parliament_period.number.ordinalize} Parliament of the United Kingdom <span class='subhead'>By-elections</span>".html_safe
    @description = "By-elections during the #{@parliament_period.number.ordinalize} Parliament of the United Kingdom."
    @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
    @crumb << { label: @parliament_period.crumb_label, url: parliament_period_show_url( :parliament_period => @parliament_period.number ) }
    @crumb << { label: 'By-elections', url: nil }
    @section = 'parliament-periods'
  end
end
