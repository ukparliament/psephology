class AddStateToElectionStates < ActiveRecord::Migration[8.1]
  def change
    add_column :election_states, :state, :integer
  end
end
