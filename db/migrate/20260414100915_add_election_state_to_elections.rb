class AddElectionStateToElections < ActiveRecord::Migration[8.1]
  def change
    add_column :elections, :election_state_id, :integer, :default => 4
    add_foreign_key :elections, :election_states
  end
end
