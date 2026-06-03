class AddIsMapAvailableToGeneralElections < ActiveRecord::Migration[8.1]
  def change
    add_column :general_elections, :is_map_available, :boolean, :default => true
  end
end
