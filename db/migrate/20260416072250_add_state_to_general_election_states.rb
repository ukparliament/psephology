class AddStateToGeneralElectionStates < ActiveRecord::Migration[8.1]
  def change
    add_column :general_election_states, :state, :integer
  end
end
