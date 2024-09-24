class ElectionController < ApplicationController
  
  def index
    general_elections = GeneralElection
      .all
      .where( 'is_notional IS FALSE')
      .order( 'polling_on' )
      
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
    
    @page_title = 'Elections'
    @description = "Elections to the Parliament of the United Kingdom."
    @crumb << { label: 'Elections', url: nil }
  end
  
  def show
    election = params[:election]
    @election = get_election( election )
    
    @general_election = @election.general_election if @election.general_election_id
    
    # We get the candidacies in the election.
    @candidacies = @election.candidacies
    
    @csv_url = election_candidate_results_url( :format => 'csv' )
    
    # If the election is part of a general election ...
    if @general_election
      @crumb << { label: 'General elections', url: general_election_list_url }
      @crumb << { label: @general_election.crumb_label, url: general_election_show_url( :general_election => @general_election ) }
      @crumb << { label: @election.constituency_group_name, url: nil }
      @section = 'general-elections'
      
    # Otherwise, if the election is a by-election ...
    else
      @crumb << { label: 'By-elections', url: by_election_list_url }
      @crumb << { label: @election.constituency_group_name, url: nil } # NOTE: Add date here when we have by-elections.
      @section = 'by-elections'
    end
    
    # If the election is notional ...
    if @election.is_notional
      
      # ... we sort the candidacy array by the highest vote count ...
      @candidacies.sort!{ |a,b| b.vote_count <=> a.vote_count }
      
      @page_title = "Notional election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}"
      @description = "Notional election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
      
      # ... and render the notional results template.
      render :template => 'election/notional_results'
      
    # Otherwise, if the election is not notional ...
    else
      
      @page_title = "Election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}"
      if @election.general_election_id
        @description = "Election for the constituency of #{@election.constituency_group_name} held as part of the general election on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
      
      else
        @description = "By-election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
      end
    
      # If the election has been held / has results ...
      if @election.has_been_held?
      
        # ... we sort the candidacy array by the highest vote count first ...
        @candidacies.sort!{ |a,b| b.vote_count <=> a.vote_count }
      
        # ... get the an array of boundary sets of which the general election containing the constituency holding the election forms part, the general election being the first held in those boundary sets ...
        @boundary_set_having_first_general_election = @election.boundary_set_having_first_general_election
        
        # ... and render the results template.
        render :template => 'election/results'
    
      # Otherwise, if the election has not been held ...  
      else
      
        # ... we render the candidacies template.
        render :template => 'election/candidacies'
      end
    end
  end
  
  def candidate_results
    election = params[:election]
    @election = get_election( election )
    
    # If the election has been held / has results ...
    if @election.has_been_held?
      
      # We get the candidacies in the election.
      @candidacies = @election.candidacies
      
      # We sort the candidacy array by the highest vote count ...
      @candidacies.sort!{ |a,b| b.vote_count <=> a.vote_count }
      
      respond_to do |format|
        format.csv {
          response.headers['Content-Disposition'] = "attachment; filename=\"results-for-#{@election.constituency_group_name.downcase.gsub( ' ', '-' )}#{'-notional' if @election.is_notional}-election-#{@election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
        }
        format.html {
        
          # If the election is part of a general election ...
          if @general_election
            @crumb << { label: 'General elections', url: general_election_list_url }
            @crumb << { label: @general_election.crumb_label, url: general_election_show_url( :general_election => @general_election ) }
            @crumb << { label: @election.constituency_group_name, url: nil }
            @section = 'general-elections'
      
          # Otherwise, if the election is a by-election ...
          else
            @crumb << { label: 'By-elections', url: by_election_list_url }
            @crumb << { label: @election.constituency_group_name, url: nil } # NOTE: Add date here when we have by-elections.
            @section = 'by-elections'
          end
    
          # If the election is notional ...
          if @election.is_notional
      
            @page_title = "Notional election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}"
            @description = "Notional election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
            render :template => 'election/notional_candidate_results'
      
          # Otherwise, if the election is not notional ...
          else
      
            @page_title = "Election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}"
            if @election.general_election_id
              @description = "Election for the constituency of #{@election.constituency_group_name} held as part of the general election on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
            else
              @description = "By-election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
            end
          end
        }
      end
    end
  end
  
  def candidacies
    election = params[:election]
    @election = get_election( election )
    
    # If the election is notional, we raise an error, listing by candidate name not being possible.
    raise ActiveRecord::RecordNotFound if @election.is_notional
    
    @general_election = @election.general_election if @election.general_election_id
    
    @candidacies = @election.candidacies
    
    # If the election is part of a general election ...
    if @general_election
      @crumb << { label: 'General elections', url: general_election_list_url }
      @crumb << { label: @general_election.crumb_label, url: general_election_show_url( :general_election => @general_election ) }
      @crumb << { label: @election.constituency_group_name, url: election_show_url }
      @crumb << { label: 'Candidacies', url: nil }
      @section = 'general-elections'
      
    # Otherwise, if the election is a by-election ...
    else
      @crumb << { label: 'By-elections', url: by_election_list_url }
      @crumb << { label: @election.constituency_group_name, url: election_show_url } # NOTE: Add date here when we have by-elections.
      @crumb << { label: 'Candidacies', url: nil }
      @section = 'by-elections'
    end
    
    @page_title = "Candidates in the election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}"
      
    if @election.general_election_id
      @description = "Candidates in the election for the constituency of #{@election.constituency_group_name} held as part of the general election on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
    else
      
      @description = "Candidates in the by-election for the constituency of #{@election.constituency_group_name} on #{@election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
    end
  end
end

def get_election( election )
  election = Election.find_by_sql( 
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
        parliament_period.number AS parliament_period_number
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
    
    
      WHERE e.id = #{election}
    "
  ).first

  raise ActiveRecord::RecordNotFound unless election
  election
end
