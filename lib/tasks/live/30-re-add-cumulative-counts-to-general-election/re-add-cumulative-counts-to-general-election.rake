# ## A task to re-generate cumulative counts on general elections.
task :re_add_cumulative_counts_on_general_elections => :environment do
  puts "re-adding cumulative counts on general elections"
  
  # We get all the general elections.
  general_elections = GeneralElection.all
  
  # For each general election ...
  general_elections.each do |general_election|
    
    # ... we set the cumulative counts to zero.
    valid_vote_count = 0
    invalid_vote_count = 0
    electorate_population_count = 0
    
    # For each election in the general election ...
    general_election.elections.each do |election|
    
      # ... we add the counts to the cumulative counts.
      valid_vote_count += election.valid_vote_count
      invalid_vote_count += election.invalid_vote_count if election.invalid_vote_count
      electorate_population_count += election.electorate.population_count
    end
    
    # We update the general election with its cumulative counts.
    general_election.valid_vote_count = valid_vote_count
    general_election.invalid_vote_count = invalid_vote_count
    general_election.electorate_population_count = electorate_population_count
    general_election.save!
  end
end