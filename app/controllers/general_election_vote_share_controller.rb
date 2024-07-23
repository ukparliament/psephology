class GeneralElectionVoteShareController < ApplicationController
  
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
    @elections = @general_election.elections_by_vote_share
    
    @csv_url = general_election_vote_share_list_url( :format => 'csv' )
    @crumb << { label: 'General elections', url: general_election_list_url }
    @crumb << { label: @general_election.crumb_label, url: general_election_party_list_url }
    @crumb << { label: 'Vote shares', url: nil }
    @section = 'general-elections'
    @subsection = 'vote-shares'
    
    if @general_election.is_notional
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - by vote share"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>By vote share</span>".html_safe
      @description = "Notional results for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listed by the vote share of the winning candidate."
      
    else
      @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - by vote share"
      @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>By vote share</span>".html_safe
      @description = "Results for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listed by the vote share of the winning candidate."
    end
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"winning-candidate-vote-shares-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
      }
      format.html{
        render :template => 'general_election_vote_share/index_notional' if @general_election.is_notional
      }
    end
  end
end
