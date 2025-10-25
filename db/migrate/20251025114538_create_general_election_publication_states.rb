class CreateGeneralElectionPublicationStates < ActiveRecord::Migration[8.0]
  def change
    create_table :general_election_publication_states do |t|
      t.string :label
      t.integer :state
      t.timestamps
    end
  end
end
