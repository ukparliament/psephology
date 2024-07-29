class GeneralElectionCountryPartyElectionController < ApplicationController
  
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
    
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    
    @elections_contested = @political_party.elections_contested_in_general_election_in_country( @general_election, @country )
    
    @first_general_election_in_boundary_set_in_country = @general_election.first_general_election_in_boundary_set_in_country( @country )
    
    @countries_having_first_elections_in_boundary_set = @general_election.countries_having_first_elections_in_boundary_set
    
    # Allow for table sorting.
    @sort = params[:sort]
    @order = params[:order]
    if @order and @sort
      case @order
      when 'descending'
        case @sort
        when 'constituency-name'
          @elections_contested.sort_by! {|election| election.constituency_name}.reverse!
        when 'candidate-name'
          @elections_contested.sort_by! {|election| election.winning_candidacy_candidate_family_name}.reverse!
        when 'electorate'
          @elections_contested.sort_by! {|election| election.electorate_population_count}.reverse!
        when 'turnout'
          @elections_contested.sort_by! {|election| election.turnout}.reverse!
        when 'vote-count'
          @elections_contested.sort_by! {|election| election.candidacy_vote_count}.reverse!
        when 'vote-share'
          @elections_contested.sort_by! {|election| election.candidacy_vote_share}.reverse!
        when 'vote-change'
          @elections_contested.sort_by! {|election| election.candidacy_vote_change || 0}.reverse!
        when 'result-position'
          @elections_contested.sort_by! {|election| election.candidacy_result_position}.reverse!
        end
      when 'ascending'
        case @sort
        when 'constituency-name'
          @elections_contested.sort_by! {|election| election.constituency_name}
        when 'candidate-name'
          @elections_contested.sort_by! {|election| election.winning_candidacy_candidate_family_name}
        when 'electorate'
          @elections_contested.sort_by! {|election| election.electorate_population_count}
        when 'turnout'
          @elections_contested.sort_by! {|election| election.turnout}
        when 'vote-count'
          @elections_contested.sort_by! {|election| election.candidacy_vote_count}
        when 'vote-share'
          @elections_contested.sort_by! {|election| election.candidacy_vote_share}
        when 'vote-change'
          @elections_contested.sort_by! {|election| election.candidacy_vote_change || 0}
        when 'result-position'
          @elections_contested.sort_by! {|election| election.candidacy_result_position}
        end
      end
    else
      @sort = 'constituency-name'
      @order = 'ascending'
    end
    
    @csv_url = general_election_country_party_election_list_url( :format => 'csv' )
    @crumb << { label: 'General elections', url: general_election_list_url }
    @crumb << { label: @general_election.crumb_label, url: general_election_party_list_url }
    @crumb << { label: @country.name, url: general_election_country_political_party_list_url }
    @crumb << { label: @political_party.name, url: general_election_country_political_party_show_url }
    @crumb << { label: 'Elections contested', url: nil }
    @section = 'general-elections'
    @subsection = 'contested'
    
    if @general_election.is_notional
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - Elections contested by #{@political_party.name}"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - Elections contested by #{@political_party.name}</span>".html_safe
      @description = "Notional results in #{@country.name} for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listing constituencies contested by #{@political_party.name}."
    else
      @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - Elections contested by #{@political_party.name}"
      @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - Elections contested by #{@political_party.name}</span>".html_safe
      @description = "Results in #{@country.name} for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listing constituencies contested by #{@political_party.name}."
    end
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"#{@political_party.hyphenated_name}-candidates-in-#{@country.name.downcase.gsub( ' ', '-' )}-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
        render :template => 'general_election_party_election/index'
      }
      format.html{
        render :template => 'general_election_country_party_election/index_notional' if @general_election.is_notional
      }
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
    
    country = params[:country]
    @country = Country.find( country )
    
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    
    @elections_won = @political_party.elections_won_in_general_election_in_country( @general_election, @country )
    
    @first_general_election_in_boundary_set_in_country = @general_election.first_general_election_in_boundary_set_in_country( @country )
    
    @countries_having_first_elections_in_boundary_set = @general_election.countries_having_first_elections_in_boundary_set
    
    # Allow for table sorting.
    @sort = params[:sort]
    @order = params[:order]
    if @order and @sort
      case @order
      when 'descending'
        case @sort
        when 'constituency-name'
          @elections_won.sort_by! {|election| election.constituency_name}.reverse!
        when 'candidate-name'
          @elections_won.sort_by! {|election| election.winning_candidacy_candidate_family_name}.reverse!
        when 'electorate'
          @elections_won.sort_by! {|election| election.electorate_population_count}.reverse!
        when 'turnout'
          @elections_won.sort_by! {|election| election.turnout}.reverse!
        when 'vote-count'
          @elections_won.sort_by! {|election| election.winning_candidacy_vote_count}.reverse!
        when 'vote-share'
          @elections_won.sort_by! {|election| election.winning_candidacy_vote_share}.reverse!
        when 'vote-change'
          @elections_won.sort_by! {|election| election.winning_candidacy_vote_change || 0}.reverse!
        when 'majority'
          @elections_won.sort_by! {|election| election.majority}.reverse!
        end
      when 'ascending'
        case @sort
        when 'constituency-name'
          @elections_won.sort_by! {|election| election.constituency_name}
        when 'candidate-name'
          @elections_won.sort_by! {|election| election.winning_candidacy_candidate_family_name}
        when 'electorate'
          @elections_won.sort_by! {|election| election.electorate_population_count}
        when 'turnout'
          @elections_won.sort_by! {|election| election.turnout}
        when 'vote-count'
          @elections_won.sort_by! {|election| election.winning_candidacy_vote_count}
        when 'vote-share'
          @elections_won.sort_by! {|election| election.winning_candidacy_vote_share}
        when 'vote-change'
          @elections_won.sort_by! {|election| election.winning_candidacy_vote_change || 0}
        when 'majority'
          @elections_won.sort_by! {|election| election.majority}
        end
      end
    else
      @sort = 'constituency-name'
      @order = 'ascending'
    end
    
    @csv_url = general_election_country_party_election_won_url( :format => 'csv' )
    @crumb << { label: 'General elections', url: general_election_list_url }
    @crumb << { label: @general_election.crumb_label, url: general_election_party_list_url }
    @crumb << { label: @country.name, url: general_election_country_political_party_list_url }
    @crumb << { label: @political_party.name, url: general_election_country_political_party_show_url }
    @crumb << { label: 'Elections won', url: nil }
    @section = 'general-elections'
    @subsection = 'won'
    
    if @general_election.is_notional
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - Elections won by #{@political_party.name}"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - Elections won by #{@political_party.name}</span>".html_safe
      @description = "Notional results in #{@country.name} for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listing constituencies won by #{@political_party.name}."
    else
      @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@country.name} - Elections won by #{@political_party.name}"
      @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@country.name} - Elections won by #{@political_party.name}</span>".html_safe
      @description = "Results in #{@country.name} for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listing constituencies won by #{@political_party.name}."
    end
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"#{@political_party.hyphenated_name}-winning-candidates-in-#{@country.name.downcase.gsub( ' ', '-' )}-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
        render :template => 'general_election_party_election/won'
      }
      format.html{
        render :template => 'general_election_country_party_election/won_notional' if @general_election.is_notional
      }
    end
  end
end
