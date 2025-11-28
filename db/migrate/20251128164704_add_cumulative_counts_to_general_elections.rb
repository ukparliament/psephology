class AddCumulativeCountsToGeneralElections < ActiveRecord::Migration[8.1]
  def change
    add_column :general_elections, :valid_vote_count, :int
    add_column :general_elections, :invalid_vote_count, :int
    add_column :general_elections, :electorate_population_count, :int
  end
end
