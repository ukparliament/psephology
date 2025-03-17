# ## A task to recalculate the cumulative electorate population count for the 2024 general election.

# We had incorrect figures for four constituencies reported by Lambeth Council, meaning we had an incorrect electorate count for the whole general election.
# This script fixes that.

task :recalculate_2024_general_election_electorate_population_count => :environment do
  puts "Recalculating the 2024 general election electorate population count"
  
  # We create a variable to hold the cumulative population count.
  cumulative_population_count = 0
  
  # We find the 2024 general election.
  general_election = GeneralElection.find( 6 )
  
  # For each election in the general election ...
  general_election.elections.each do |election|
  
    # ... we add the electorate population count to the cumulative count.
    cumulative_population_count += election.electorate.population_count
    
    # We update the general election electorate population count.
    general_election.electorate_population_count = cumulative_population_count
    general_election.save!
  end
end