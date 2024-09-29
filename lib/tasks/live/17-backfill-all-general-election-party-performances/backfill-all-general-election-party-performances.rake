# ## A task to backfill all general election party performances.
task :backfill_all_general_election_party_performances => :environment do
  puts "backfilling all general election party performances"
  
  # We get all the general elections.
  general_elections = GeneralElection.all
  
  # We get all the political parties.
  political_parties = PoliticalParty.all
  
  # For each political party ...
  political_parties.each do |political_party|
    
    # ... for each general election ...
    general_elections.each do |general_election|
      
      # ... we attempt to find the general election party performance for this party.
      general_election_party_performance = GeneralElectionPartyPerformance
        .all
        .where( "general_election_id = ?", general_election.id )
        .where( "political_party_id = ?", political_party.id )
        .first
      
      # Unless we find the general election party performance for this party ...
      unless general_election_party_performance
        
        # ... we create a general election party performance with all counts set to zero.
        general_election_party_performance = GeneralElectionPartyPerformance.new
        general_election_party_performance.general_election = general_election
        general_election_party_performance.political_party = political_party
        general_election_party_performance.constituency_contested_count = 0
        general_election_party_performance.constituency_won_count = 0
        general_election_party_performance.cumulative_vote_count = 0
        general_election_party_performance.cumulative_valid_vote_count = 0
        
        # For each election forming part of the general election ...
        general_election.elections.each do |election|
        
          # ... if a candidacy representing the political party is in the election ...
          if political_party.represented_in_election?( election )
          
            # ... we increment the constituency contested count.
            general_election_party_performance.constituency_contested_count += 1
          
            # We add the vote count of the party candidate to the cumulative vote count.
            general_election_party_performance.cumulative_vote_count += election.political_party_candidacy( political_party ).vote_count
          
            # We add the valid vote count in the election to the cumulative valid vote count.
            general_election_party_performance.cumulative_valid_vote_count += election.valid_vote_count
          
            # If the winning candidacy in the election represented the political party ...
            if political_party.won_election?( election )
          
              # ... we increment the constituency won count.
              general_election_party_performance.constituency_won_count += 1
            end
          end
        
          # We save the general election party performance record.
          general_election_party_performance.save!
        end
      end
    end
  end
end