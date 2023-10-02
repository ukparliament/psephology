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
    
    # Otherwise, if first candidacy does not have a vote count ...  
    else
      
      # ... we render the candidacies template.
      render :template => 'election/candidacies'
    end
  end
  
  def candidacies
    election = params[:election]
    @election = Election.find_by_sql( 
      "
        SELECT e.*, cg.name AS constituency_group_name, cg.constituency_area_id AS constituency_area_id
        FROM elections e, constituency_groups cg
        WHERE e.id = #{election}
        AND e.constituency_group_id = cg.id
      "
    ).first
    
    @page_title = "Election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}"
    
    @candidacies = @election.candidacies
  end
  
  def results
    election = params[:election]
    @election = get_election( election )
    
    @page_title = "Election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}"
    
    @candidacies = @election.results
  end
end

def get_election( election )
  Election.find_by_sql( 
    "
      SELECT e.*,
        constituency_group.name AS constituency_group_name,
        constituency_group.constituency_area_id AS constituency_area_id,
        winning_candidacy.candidate_given_name AS winning_candidate_given_name,
        winning_candidacy.candidate_family_name AS winning_candidate_family_name,
        electorate.population_count AS electorate_population_count
      FROM elections e
    
      RIGHT JOIN (
        SELECT cg.id AS id, cg.name AS name, cg.constituency_area_id AS constituency_area_id
        FROM constituency_groups cg
      ) constituency_group
      ON constituency_group.id = e.constituency_group_id
    
      LEFT JOIN (
        SELECT c.election_id AS election_id, c.candidate_given_name AS candidate_given_name, c.candidate_family_name AS candidate_family_name
        FROM candidacies c
        WHERE is_winning_candidacy IS TRUE
      ) winning_candidacy
      ON winning_candidacy.election_id = e.id
    
      LEFT JOIN (
        SELECT e.election_id AS election_id, e.population_count AS population_count
        FROM electorates e
      ) electorate
      ON electorate.election_id = e.id
    
    
      WHERE e.id = #{election}
    "
  ).first
end
