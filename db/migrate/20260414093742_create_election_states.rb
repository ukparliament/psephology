class CreateElectionStates < ActiveRecord::Migration[8.1]
  def change
    create_table :election_states do |t|
      t.string :label

      t.timestamps
    end
  end
end
