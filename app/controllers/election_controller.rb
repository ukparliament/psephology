class ElectionController < ApplicationController
  
  def index
    @page_title = 'Elections'
    general_elections = GeneralElection.all.order( 'polling_on' )
    by_elections = Election.find_by_sql(
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg
        WHERE e.constituency_group_id = cg.id
        AND e.general_election_id IS NULL
        ORDER BY polling_on DESC, constituency_group_name
      "
    )
    
    # We create an array to hold election listing items.
    @election_listing_items = []
    
    # For each general election ...
    general_elections.each do |general_election|
      
      # ... we create an election listing item.
      election_listing_item = ElectionListingItem.new
      election_listing_item.id = general_election.id
      election_listing_item.type = 'general'
      election_listing_item.polling_on = general_election.polling_on
      election_listing_item.constituency_group_name = 'a'
      
      # We add the election listing item to the election listing items array.
      @election_listing_items << election_listing_item
    end
    
    # For each by-election ...
    by_elections.each do |by_election|
      
      # ... we create an election listing item.
      election_listing_item = ElectionListingItem.new
      election_listing_item.id = by_election.id
      election_listing_item.type = 'by'
      election_listing_item.polling_on = by_election.polling_on
      election_listing_item.constituency_group_name = by_election.constituency_group_name
      
      # We add the election listing item to the election listing items array.
      @election_listing_items << election_listing_item
    end
    
    # We sort the mixed array of general elections and by-elections by the polling_on date.
    @election_listing_items.sort!{ |a,b| b.polling_on <=> a.polling_on }
  end
  
  def show
    election = params[:election]
    @election = get_election( election )
    
    @page_title = "Election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}"
    
    # We get the candidacies in the election.
    @candidacies = @election.candidacies
    
    # If the election has been held / has resultss ...
    if @election.has_been_held?
      
      # ... we sort the candidacy array by the highest vote count ...
      @candidacies.sort!{ |a,b| b.vote_count <=> a.vote_count }
      
      # ... and render the results template.
      render :template => 'election/results'
    
    # Otherwise, if the election has not been held ...  
    else
      
      # ... we render the candidacies template.
      render :template => 'election/candidacies'
    end
  end
  
  def candidacies
    election = params[:election]
    @election = get_election( election )
    
    @page_title = "Election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}"
    
    @candidacies = @election.candidacies
  end
  
  def results
    election = params[:election]
    @election = get_election( election )
    
    @page_title = "Election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}"
    
    @candidacies = @election.results
    
    render :layout => 'd3'
  end
  
  def results_candidacies
    election = params[:election]
    @election = get_election( election )
    
    @page_title = "Election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - chart"
    
    @multiline_page_title = "Election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Chart</span>".html_safe
    
    @candidacies = @election.results
    
    render :layout => 'd3'
  end
end

def get_election( election )
  Election.find_by_sql( 
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
        general_election.polling_on AS general_election_polling_on
      FROM elections e
      
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
    
    
      WHERE e.id = #{election}
    "
  ).first
end
