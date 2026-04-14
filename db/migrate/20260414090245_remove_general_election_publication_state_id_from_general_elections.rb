class RemoveGeneralElectionPublicationStateIdFromGeneralElections < ActiveRecord::Migration[8.1]
  def change
    remove_column :general_elections, :general_election_publication_state_id, :integer
  end
end
