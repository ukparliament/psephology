class RemoveCumulativeCountsFromGeneralElection < ActiveRecord::Migration[8.1]
  def change
    remove_column :general_elections, :valid_vote_count, :integer
    remove_column :general_elections, :invalid_vote_count, :integer
    remove_column :general_elections, :electorate_population_count, :integer
  end
end
