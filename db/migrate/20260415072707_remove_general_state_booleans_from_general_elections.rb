class RemoveGeneralStateBooleansFromGeneralElections < ActiveRecord::Migration[8.1]
  def change
    remove_column :general_elections, :are_all_winners_known, :boolean
    remove_column :general_elections, :are_all_full_results_known, :boolean
  end
end
