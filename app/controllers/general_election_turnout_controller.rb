class GeneralElectionTurnoutController < ApplicationController
  
  def index
    @elections = @general_election.elections_by_turnout
    
   respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"turnout-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
      }
      format.html{
        @page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - by turnout"
        @multiline_page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>By turnout</span>".html_safe
        @description = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listed by turnout."
        @csv_url = general_election_turnout_list_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: 'Turnouts', url: nil }
        @section = 'elections'
        @subsection = 'turnouts'
        render :template => 'general_election_turnout/index_notional' if @general_election.is_notional
      }
    end
  end
end
