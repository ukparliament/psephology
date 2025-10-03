class DropUnusedTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :general_election_party_performances
    drop_table :country_general_election_party_performances
    drop_table :english_region_general_election_party_performances
  end
end
