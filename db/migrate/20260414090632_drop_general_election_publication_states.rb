class DropGeneralElectionPublicationStates < ActiveRecord::Migration[8.1]
  def change
    drop_table :general_election_publication_states
  end
end
