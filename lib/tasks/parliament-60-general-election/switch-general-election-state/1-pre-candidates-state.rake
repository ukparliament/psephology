# ## A task to switch the general election for Parliament 60 into pre-candidates state.
task :switch_parliament_60_general_election_to_pre_candidates_state => :environment do
  puts "switching Parliament 60 general election to pre-candidates state"
  
  # We find the general election for Parliament 60 ...
  general_election = GeneralElection.where( 'parliament_period_id = 60' ).first
  
  # ... and switch it into pre-candidates state.
  general_election.general_election_state_id = 1
  general_election.save!
end