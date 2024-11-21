# ## A task to add writ issued on dates to elections in a general election.
task :add_writ_issued_on_dates_to_elections_in_a_general_election => :environment do
  puts "adding writ issued on dates to elections in a general election"
  
  # We get all non-notional elections in a general election.
  elections = Election.find_by_sql(
    "
      SELECT *
      FROM elections
      WHERE general_election_id IS NOT NULL
      AND is_notional IS FALSE
    "
  )
  
  # For all non-notional elections in a general election ...
  elections.each do |election|
  
    # ... we set the writ issued on date to the dissolution date of the preceding Parliament.
    election.writ_issued_on = election.parliament_period.previous_parliament_period.dissolved_on
    election.save!
  end
end





