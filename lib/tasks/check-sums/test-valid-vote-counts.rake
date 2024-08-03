# ## A task to check whether valid vote counts for an election agree with the vote total acoss all candidates.
task :test_valid_vote_count => :environment do
  puts "checking whether valid vote counts for an election agree with the vote total acoss all candidates"
  
  # We get all the elections.
  elections = Election.all
  
  # For each election ...
  elections.each do |election|
    
    # ... we set the cumulative vote count to zero.
    cumulative_vote_count = 0
    
    # For each candidacy in the election ...
    election.candidacies.each do |candidacy|
      
      # ... we add the vote count of the candidacy to the cumulative vote count.
      cumulative_vote_count += candidacy.vote_count
    end
    
    # If the valid vote count for the election does not equal the cumulative vote count for its candidacies ...
    if election.valid_vote_count != cumulative_vote_count
      
      # ... we report an error.
      puts "Election #{election.id} has a valid vote count of #{election.valid_vote_count} and a cumulative vote count of #{cumulative_vote_count}"
    end
  end
end