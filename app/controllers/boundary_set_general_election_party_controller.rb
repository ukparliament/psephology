class BoundarySetGeneralElectionPartyController < ApplicationController
  
  def index
    @boundary_set = get_boundary_set
    
    # We get all elections being part of a general election having winners announced.
    @general_elections = @boundary_set.general_elections_with_winners
    
    # We get all political parties having won an election as part of a general election in this boundary set.
    @political_parties = @boundary_set.general_election_winning_political_parties
    
    # We get a count of elections won by a political party in a general election in a boundary set.
    @elections_won = @boundary_set.election_won_count_in_general_election_by_political_party
    
    # For each political party ...
    @political_parties.each do |political_party|
    
      # ... we create an array to hold party performances in general elections.
      party_performances_in_general_elections = []
    
      # ... for each general election ...
      @general_elections.each do |general_election|
      
        # ... want to store a copy of the general election with a win count for each political party ...
        # ... so we clone the general election.
        general_election_clone = general_election.clone
      
        # ... we check if the elections won array contains an entry for the political party in this general election.
        # We first run a select to get an array of elections won in this general election ...
        # ... then a find to return an election won in that array by this political party.
        election_won_count = @elections_won
          .select{ |ew| ew.general_election_id == general_election.id}
          .find{|ew| ew.political_party_id == political_party.id }
          
        # If we find an election won count for this political party in this general election ...
        if election_won_count
        
          # ... we set the won count on the cloned general election.
          general_election_clone.won_count = election_won_count.election_won_count
          
        # Otherwise, if we don't find an election won count for this political party in this general election ...
        else
        
          # ... we set the won count on the general election to zero.
          general_election_clone.won_count = 0
        end
        
        # We add the cloned general election to the party performance in general election array.
        party_performances_in_general_elections << general_election_clone
      end
      
      # We add the party performance in general election array to the political party.
      political_party.party_performances_in_general_election = party_performances_in_general_elections
    end
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - general election party performance"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>General election party performance</span>".html_safe
    @description = "Party performances in general elections in #{@boundary_set.country_name} held during the existence of the #{@boundary_set.display_title} boundary set."
    @crumb << { label: 'Boundary sets', url: boundary_set_list_url }
    @crumb << { label: @boundary_set.display_title, url: boundary_set_show_url( :boundary_set => @boundary_set ) }
    @crumb << { label: 'Party performances', url: nil }
    @section = 'boundary-sets'
    @subsection = 'parties'
  end
end
