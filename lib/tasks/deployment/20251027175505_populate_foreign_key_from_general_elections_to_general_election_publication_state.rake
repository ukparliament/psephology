namespace :after_party do
  desc 'Deployment task: populate_foreign_key_from_general_elections_to_general_election_publication_state'
  task populate_foreign_key_from_general_elections_to_general_election_publication_state: :environment do
    puts "Running deploy task 'populate_foreign_key_from_general_elections_to_general_election_publication_state'"

    # Put your task implementation HERE.
    GeneralElection.all.each do |ge|
      ge.update!(general_election_publication_state_id: 3)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end