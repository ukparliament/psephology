namespace :after_party do
  desc 'Deployment task: populate_general_election_publication_states'
  task populate_general_election_publication_states: :environment do
    puts "Running deploy task 'populate_general_election_publication_states'"

    # Put your task implementation HERE.
    GeneralElectionPublicationState.create(label: "Unpublished", state: 0)
    GeneralElectionPublicationState.create(label: "Pre-election candidates", state: 1)
    GeneralElectionPublicationState.create(label: "Post-election winners", state: 2)
    GeneralElectionPublicationState.create(label: "Post-election votes", state: 3)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end