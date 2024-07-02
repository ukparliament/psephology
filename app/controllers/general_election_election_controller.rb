class GeneralElectionElectionController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find_by_sql(
      "
        SELECT ge.*, pp.number AS parliament_period_number
        FROM general_elections ge, parliament_periods pp
        WHERE ge.parliament_period_id = pp.id
        AND ge.id = #{general_election}
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @general_election
    @elections = @general_election.elections
    
    @section = 'general-elections'
    @csv_url = general_election_election_list_url( :format => 'csv' )
    @crumb = "<li><a href='/general-elections'>General elections</a></li>"
    if @general_election.is_notional
      
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - elections"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Elections</span>".html_safe
      @description = "Elections forming part of the notional general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
      @crumb += "<li><a href='/general-elections/#{@general_election.id}/political-parties'>#{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} (Notional)</a></li>"
      @crumb += "<li>Elections</li>"
    else
    
      @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - elections"
      @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Elections</span>".html_safe
      @description = "Elections taking place as part of the general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
      @crumb += "<li><a href='/general-elections/#{@general_election.id}/political-parties'>#{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}</a></li>"
      @crumb += "<li>Elections</li>"
    end
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"elections-in-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
      }
      format.html{
        render :template => 'general_election_election/index_notional' if @general_election.is_notional
      }
    end
  end
end
