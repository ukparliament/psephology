class GeneralElectionElectionController < ApplicationController
  
  def index
    @elections = @general_election.elections
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"elections-in-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
      }
      format.html{
        @page_title = "#{@general_election.result_type} for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - elections"
        @multiline_page_title = "#{@general_election.result_type} for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Elections</span>".html_safe
        @description = "Elections taking place as part of #{@general_election.noun_phrase_article} #{@general_election.general_election_type.downcase} to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
        @csv_url = general_election_election_list_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: 'Elections', url: nil }
        @section = 'elections'
        render :template => 'general_election_election/index_notional' if @general_election.is_notional
      }
    end
  end
end
