class ParliamentPeriodMaidenSpeechController < ApplicationController

  def index
    parliament_period = params[:parliament_period]
    @parliament_period = ParliamentPeriod.find_by_number( parliament_period )
    raise ActiveRecord::RecordNotFound unless @parliament_period
    
    @maiden_speeches = @parliament_period.maiden_speeches
    
    # Allow for table sorting.
    @sort = params[:sort]
    @order = params[:order]
    if @order and @sort
      case @order
      when 'descending'
        case @sort
        when 'member-name'
          @maiden_speeches.sort_by! {|ms| ms.member_family_name}.reverse! # add given name here
        when 'constituency-name'
          @maiden_speeches.sort_by! {|ms| ms.constituency_group_name}.reverse!
        when 'date-made'
          @maiden_speeches.sort_by! {|ms| ms.made_on}.reverse!
        when 'session'
          @maiden_speeches.sort_by! {|ms| ms.session_number}.reverse!
        end
      when 'ascending'
        case @sort
        when 'member-name'
          @maiden_speeches.sort_by! {|ms| ms.member_family_name}
        when 'constituency-name'
          @maiden_speeches.sort_by! {|ms| ms.constituency_group_name}
        when 'date-made'
          @maiden_speeches.sort_by! {|ms| ms.made_on}
        when 'session'
          @maiden_speeches.sort_by! {|ms| ms.session_number}
        end
      end
    else
      @sort = 'date-made'
      @order = 'ascending'
    end
    
    @page_title = "#{@parliament_period.number.ordinalize} Parliament of the United Kingdom - maiden speeches"
    @multiline_page_title = "#{@parliament_period.number.ordinalize} Parliament of the United Kingdom <span class='subhead'>Maiden speeches</span>".html_safe
    @description = "Maiden speeches made during the #{@parliament_period.number.ordinalize} Parliament of the United Kingdom."
    @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
    @crumb << { label: @parliament_period.crumb_label, url: parliament_period_show_url( :parliament_period => @parliament_period.number ) }
    @crumb << { label: 'Maiden speeches', url: nil }
    @section = 'parliament-periods'
    @subsection = 'maiden-speeches'
  end
end
