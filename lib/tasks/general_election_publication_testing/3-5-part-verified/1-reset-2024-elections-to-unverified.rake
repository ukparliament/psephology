# A task to reset 2024 elections to unverified.
task :reset_2024_elections_to_unverified => :environment do

  # We find the general election.
  general_election = GeneralElection.find( GENERAL_ELECTION_ID )
  
  # For each election in the general election ...
  general_election.elections_without_electorate.each do |election|
  
    # ... we reset is verified to false.
    election.is_verified = false
    election.save!
  end
end