class DropGeneralElectioPartyPerformanceTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :general_election_party_performances
  end
end
