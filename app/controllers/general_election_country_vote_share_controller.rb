class GeneralElectionCountryVoteShareController < ApplicationController
  
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
    
    country = params[:country]
    @country = Country.find( country )
    
    @elections = @general_election.elections_by_vote_share_in_country( @country )
    
    @csv_url = general_election_country_vote_share_list_url( :format => 'csv' )
    @crumb = "<li><a href='/general-elections'>General elections</a></li>"
    @crumb += "<li><a href='/general-elections/#{@general_election.id}/political-parties'>#{@general_election.crumb_label}</a></li>"
    @crumb += "<li><a href='/general-elections/#{@general_election.id}/countries/#{@country.id}/political-parties'>#{@country.name}</a></li>"
    @crumb += "<li>Vote shares</li>"
    @section = 'general-elections'
    @subsection = 'vote-shares'
    
    if @general_election.is_notional
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - by vote share"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - by vote share</span>".html_safe
      @description = "Notional results in #{@country.name} for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by the vote share of the winning candidate."
      
    else
      @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - by vote share"
      @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - by vote share</span>".html_safe
      @description = "Results in #{@country.name} for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by the vote share of the winning candidate."
    end
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"winning-candidate-vote-share-in-#{@country.name.downcase.gsub( ' ', '-' )}-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
        render :template => 'general_election_vote_share/index'
      }
      format.html{
        render :template => 'general_election_country_vote_share/index_notional' if @general_election.is_notional
      }
    end
  end 
end
