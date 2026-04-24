class AddAreAggregationsAvailableToGeneralElections < ActiveRecord::Migration[8.1]
  def change
    add_column :general_elections, :are_aggregations_available, :boolean, :default => true
  end
end
