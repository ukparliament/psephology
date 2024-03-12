class GeneralElectionCountryPoliticalPartyController < ApplicationController
  
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
    
    @party_performances = @general_election.party_performance_in_country( @country )
    
    @valid_vote_count_in_general_election_in_country = @general_election.valid_vote_count_in_country( @country )
    
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - by party"
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - by party</span>".html_safe
  end
  
  def show

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
    
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    
    @page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - #{@political_party.name}"
    @multiline_page_title = "UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - #{@political_party.name}</span>".html_safe
  end
end
