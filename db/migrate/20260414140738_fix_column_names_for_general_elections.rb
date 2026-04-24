class FixColumnNamesForGeneralElections < ActiveRecord::Migration[8.1]
  def change
    rename_column :general_elections, :is_map_available, :are_all_winners_known
    rename_column :general_elections, :are_aggregations_available, :are_all_full_results_known
  end
end
