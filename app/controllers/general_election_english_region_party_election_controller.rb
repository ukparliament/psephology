class GeneralElectionEnglishRegionPartyElectionController < ApplicationController
  
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
    
    country = params[:country]
    english_region = params[:english_region]
    @english_region = EnglishRegion.all.where( 'id = ?', english_region ).where( 'country_id =?', country).first
    
    raise ActiveRecord::RecordNotFound unless @general_election and @english_region
    
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    
    @elections_contested = @political_party.elections_contested_in_general_election_in_english_region( @general_election, @english_region )
    
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
    
    @crumb = "<li><a href='/general-elections'>General elections</a></li>"
    @crumb += "<li><a href='/general-elections/#{@general_election.id}/political-parties'>#{@general_election.crumb_label}</a></li>"
    @crumb += "<li><a href='/general-elections/#{@general_election.id}/countries/2/political-parties'>England</a></li>"
    @crumb += "<li><a href='/general-elections/#{@general_election.id}/countries/2/english-regions/#{@english_region.id}/political-parties'>#{@english_region.name}</a></li>"
    @crumb += "<li><a href='/general-elections/#{@general_election.id}/countries/2/english-regions/#{@english_region.id}/political-parties/#{@political_party.id}'>#{@political_party.name}</a></li>"
    @crumb += "<li>Elections contested</li>"
    @section = 'general-elections'
    @subsection = 'contested'
    
    if @general_election.is_notional
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - Elections contested by #{@political_party.name}"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - Elections contested by #{@political_party.name}</span>".html_safe
      @description = "Notional results in #{@english_region.name}, England for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listing constituencies contested by #{@political_party.name}."
      render :template => 'general_election_english_region_party_election/index_notional'
    else
      @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - Elections contested by #{@political_party.name}"
      @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - Elections contested by #{@political_party.name}</span>".html_safe
      @description = "Results in #{@english_region.name}, England for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listing constituencies contested by #{@political_party.name}."
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
    
    country = params[:country]
    english_region = params[:english_region]
    @english_region = EnglishRegion.all.where( 'id = ?', english_region ).where( 'country_id =?', country).first
    
    raise ActiveRecord::RecordNotFound unless @general_election and @english_region
    
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    
    @elections_won = @political_party.elections_won_in_general_election_in_english_region( @general_election, @english_region )
    
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
    
    @crumb = "<li><a href='/general-elections'>General elections</a></li>"
    @crumb += "<li><a href='/general-elections/#{@general_election.id}/political-parties'>#{@general_election.crumb_label}</a></li>"
    @crumb += "<li><a href='/general-elections/#{@general_election.id}/countries/2/political-parties'>England</a></li>"
    @crumb += "<li><a href='/general-elections/#{@general_election.id}/countries/2/english-regions/#{@english_region.id}/political-parties'>#{@english_region.name}</a></li>"
    @crumb += "<li><a href='/general-elections/#{@general_election.id}/countries/2/english-regions/#{@english_region.id}/political-parties/#{@political_party.id}'>#{@political_party.name}</a></li>"
    @crumb += "<li>Elections won</li>"
    @section = 'general-elections'
    @subsection = 'won'
    
    if @general_election.is_notional
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - Elections won by #{@political_party.name}"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - Elections won by #{@political_party.name}</span>".html_safe
      @description = "Notional results in #{@english_region.name}, England for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listing constituencies won by #{@political_party.name}."
      render :template => 'general_election_english_region_party_election/won_notional'
    else
      @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - Elections won by #{@political_party.name}"
      @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - Elections won by #{@political_party.name}</span>".html_safe
      @description = "Results in #{@english_region.name}, England for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listing constituencies won by #{@political_party.name}."
    end
  end
end
