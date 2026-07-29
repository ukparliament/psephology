# ## A task to switch the general election for Parliament 60 into full results state.
task :switch_parliament_60_general_election_to_full_results_state => :environment do
  puts "switching Parliament 60 general election to full results state"
  
  # We find the general election for Parliament 60 ...
  general_election = GeneralElection.where( 'parliament_period_id = 60' ).first
  
  # ... and switch it into full results state.
  general_election.general_election_state_id = 4
  general_election.save!
end