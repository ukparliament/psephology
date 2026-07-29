# ## A task to switch the general election for Parliament 60 into winners only state.
task :switch_parliament_60_general_election_to_winners_only_state => :environment do
  puts "switching Parliament 60 general election to winners only state"
  
  # We find the general election for Parliament 60 ...
  general_election = GeneralElection.where( 'parliament_period_id = 60' ).first
  
  # ... and switch it into winners only state.
  general_election.general_election_state_id = 3
  general_election.save!
end