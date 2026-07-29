class AddElectionManagerIdToElections < ActiveRecord::Migration[8.1]
  def change
    add_column :elections, :election_manager_id, :integer
  end
end
