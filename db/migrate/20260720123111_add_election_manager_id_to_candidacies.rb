class AddElectionManagerIdToCandidacies < ActiveRecord::Migration[8.1]
  def change
    add_column :candidacies, :election_manager_id, :integer
  end
end
