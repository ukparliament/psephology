class ElectionController < ApplicationController
  
  def index
    @page_title = 'Elections'
    @description = 'Elections to the Parliament of the United Kingdom.'
    @crumb << { label: 'Elections', url: nil }
    @section = 'elections'
  
    @general_elections = GeneralElection.find_by_sql(
      "
        SELECT ge.*, count(e.*) AS election_count, pp.number AS parliament_period_number, pp.summoned_on AS parliament_period_summoned_on, pp.dissolved_on AS parliament_period_dissolved_on
        FROM general_elections ge, elections e, parliament_periods pp
        WHERE e.general_election_id = ge.id
        AND ge.is_notional IS FALSE
        AND ge.parliament_period_id = pp.id
        GROUP BY ge.id, pp.id
        ORDER BY polling_on DESC
      "
    )
    
    @parliament_periods_with_by_elections = ParliamentPeriod.find_by_sql(
      "
        SELECT p.*, count(e.*) AS by_election_count
        FROM parliament_periods p, elections e
        WHERE p.id = e.parliament_period_id
        AND e.general_election_id IS NULL
        GROUP BY p.id
        ORDER BY p.summoned_on DESC
      "
    )
    
    @notional_general_elections = GeneralElection.find_by_sql(
      "
        SELECT ge.*, count(e.*) AS election_count, pp.number AS parliament_period_number, pp.summoned_on AS parliament_period_summoned_on, pp.dissolved_on AS parliament_period_dissolved_on
        FROM general_elections ge, elections e, parliament_periods pp
        WHERE e.general_election_id = ge.id
        AND ge.is_notional IS TRUE
        AND ge.parliament_period_id = pp.id
        GROUP BY ge.id, pp.id
        ORDER BY polling_on DESC
      "
    )
  end
  
  def show
    election = params[:election]
    @election = get_election( election )
    
    @general_election = @election.general_election_with_publication_state if @election.general_election_id
    
    # We get the candidacy results in the election.
    @candidacies = @election.results
    
    @page_title = "#{@election.election_type} for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}"
    @meta_page_title = "#{@election.constituency_group_name} #{@election.election_type.downcase} - #{@election.polling_on.strftime( $CRUMB_DATE_DISPLAY_FORMAT )}"
    @description = @election.description
    @csv_url = election_candidate_results_url( :format => 'csv' )
    @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
    @crumb << { label: @election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @election.parliament_period_number) }
    if @election.general_election_id
      @crumb << { label: @general_election.crumb_label, url: general_election_show_url( :general_election => @general_election ) }
      @crumb << { label: @election.constituency_group_name, url: nil }
    else
      @crumb << { label: "By-elections", url: parliament_period_by_election_list_url( :parliament_period => @election.parliament_period_number ) }
      @crumb << { label: @election.by_election_label, url: nil }
    end
    @section = 'elections'
    
    # If the election is notional ...
    if @election.is_notional
    
      # ... we render the notional results template.
      render :template => 'election/notional_show'
      
    # Otherwise, if the election is not notional ...
    else
    
      # ... we get the an array of boundary sets of which the general election containing the constituency holding the election forms part, the general election being the first held in those boundary sets ...
      @boundary_set_having_first_general_election = @election.boundary_set_having_first_general_election
      
      # If the election forms part of a general election ...
      if @general_election
      
        # ... and that general election only has candidate lists ...
        if @general_election.publication_state == 1
        
          # ... we order the candidacies by family name, then given name.
          @candidacies.sort_by! {|candidacy| candidacy.candidate_given_name}.sort_by! {|candidacy| candidacy.candidate_family_name}
          
          # We render the candidates only template.
          render :template => 'election/show_candidates_only'
        end
      end
    end
  end
  
  def candidate_results
    election = params[:election]
    @election = get_election( election )
    
    @general_election = @election.general_election if @election.general_election_id
      
    # We get the candidacy results in the election.
    @candidacies = @election.results
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"results-for-#{@election.constituency_group_name.downcase.gsub( ' ', '-' )}#{'-notional' if @election.is_notional}-election-#{@election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
      }
      format.html {
      
        @page_title = "#{@election.election_type} for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}"
        @description = @election.description
        @csv_url = election_candidate_results_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @election.parliament_period_number) }
        if @election.general_election_id
          @crumb << { label: @general_election.crumb_label, url: general_election_show_url( :general_election => @general_election ) }
          @crumb << { label: @election.constituency_group_name, url: election_show_url }
        else
          @crumb << { label: "By-elections", url: parliament_period_by_election_list_url( :parliament_period => @election.parliament_period_number ) }
          @crumb << { label: @election.by_election_label, url: election_show_url }
        end
        @crumb << { label: 'Results', url: nil }
        @section = 'elections'
      
        # If the election is notional ...
        if @election.is_notional
          
          # ... we render the notional candidate results template.
          render :template => 'election/notional_candidate_results'
        end
      }
    end
  end
end

def get_election( election_id )
  election = Election.find_by_sql([
    "
      SELECT e.*,
        ( cast(e.majority as decimal) / e.valid_vote_count ) AS majority_percentage,
        constituency_group.name AS constituency_group_name,
        constituency_area.constituency_area_id AS constituency_area_id,
        winning_candidacy.candidate_given_name AS winning_candidate_given_name,
        winning_candidacy.candidate_family_name AS winning_candidate_family_name,
        electorate.population_count AS electorate_population_count,
        result_summary.short_summary AS result_summary_short_summary,
        result_summary.summary AS result_summary_summary,
        general_election.polling_on AS general_election_polling_on,
        parliament_period.number AS parliament_period_number,
        parliament_period.summoned_on AS parliament_period_summoned_on,
        parliament_period.dissolved_on AS parliament_period_dissolved_on
      FROM elections e
      
      INNER JOIN (
        SELECT pp.*
        FROM parliament_periods pp
      ) parliament_period
      ON parliament_period.id = e.parliament_period_id
      
      INNER JOIN (
        SELECT cg.id AS id, cg.name AS name
        FROM constituency_groups cg
      ) constituency_group
      ON constituency_group.id = e.constituency_group_id
      
      LEFT JOIN (
        SELECT cg.id AS constituency_group_id, ca.id AS constituency_area_id
        FROM constituency_groups cg, constituency_areas ca
        WHERE cg.constituency_area_id = ca.id
      ) constituency_area
      ON constituency_area.constituency_group_id = e.constituency_group_id
    
      LEFT JOIN (
        SELECT c.election_id AS election_id, c.candidate_given_name AS candidate_given_name, c.candidate_family_name AS candidate_family_name
        FROM candidacies c
        WHERE is_winning_candidacy IS TRUE
      ) winning_candidacy
      ON winning_candidacy.election_id = e.id
    
      LEFT JOIN (
        SELECT *
        FROM result_summaries rs
      ) result_summary
      ON result_summary.id = e.result_summary_id
    
      LEFT JOIN (
        SELECT e.id AS electorate_id, e.population_count AS population_count
        FROM electorates e
      ) electorate
      ON electorate.electorate_id = e.electorate_id
    
      LEFT JOIN (
        SELECT *
        FROM general_elections
      ) general_election
      ON general_election.id = e.general_election_id
    
      WHERE e.id = ?
    ", election_id
  ]).first

  raise ActiveRecord::RecordNotFound unless election
  election
end
