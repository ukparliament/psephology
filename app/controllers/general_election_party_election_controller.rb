class GeneralElectionPartyElectionController < ApplicationController
  
  def index
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    @elections_contested = @political_party.elections_contested_in_general_election( @general_election )
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
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"#{@political_party.hyphenated_name}-candidates-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
      }
      format.html{
        @page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Elections contested by #{@political_party.name}"
        @multiline_page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Elections contested by #{@political_party.name}</span>".html_safe
        @description = "Elections contested by #{@political_party.name} in #{@general_election.noun_phrase_article} #{@general_election.general_election_type.downcase} to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
        @csv_url = general_election_party_election_list_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: @political_party.name, url: general_election_party_show_url }
        @crumb << { label: 'Elections contested', url: nil }
        @section = 'elections'
        @subsection = 'contested'
        render :template => 'general_election_party_election/index_notional' if @general_election.is_notional
      }
    end
  end
  
  def won
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    @elections_won = @political_party.elections_won_in_general_election( @general_election )
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
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"#{@political_party.hyphenated_name}-winning-candidates-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
      }
      format.html{
        @page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - Elections won by #{@political_party.name}"
        @multiline_page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Elections won by #{@political_party.name}</span>".html_safe
        @description = "Elections won by #{@political_party.name} in #{@general_election.noun_phrase_article} #{@general_election.general_election_type.downcase} to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
        @csv_url = general_election_party_election_won_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: @political_party.name, url: general_election_party_show_url }
        @crumb << { label: 'Elections won', url: nil }
        @section = 'elections'
        @subsection = 'won'
        render :template => 'general_election_party_election/won_notional' if @general_election.is_notional
      }
    end
  end
end
