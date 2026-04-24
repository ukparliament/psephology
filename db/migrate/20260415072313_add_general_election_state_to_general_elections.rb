class AddGeneralElectionStateToGeneralElections < ActiveRecord::Migration[8.1]
  def change
    add_column :general_elections, :general_election_state_id, :integer, :default => 4
    add_foreign_key :general_elections, :general_election_states
  end
end
