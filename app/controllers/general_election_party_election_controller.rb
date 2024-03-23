class GeneralElectionPartyElectionController < ApplicationController
  
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
    
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    
    @elections_contested = @political_party.elections_contested_in_general_election( @general_election )
    
    if @general_election.is_notional
      
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Elections contested by #{@political_party.name}"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Elections contested by #{@political_party.name}</span>".html_safe
      
      render :template => 'general_election_party_election/index_notional'
    else
    
      @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Elections contested by #{@political_party.name}"
      @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Elections contested by #{@political_party.name}</span>".html_safe
    end
  end
  
  def won
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
    
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    
    @elections_won = @political_party.elections_won_in_general_election( @general_election )
    
    if @general_election.is_notional
      
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Elections won by #{@political_party.name}"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Elections won by #{@political_party.name}</span>".html_safe
      
      render :template => 'general_election_party_election/won_notional'
    else
    
      @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Elections won by #{@political_party.name}"
      @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Elections won by #{@political_party.name}</span>".html_safe
    end
  end
end
