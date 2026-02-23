class RemoveElectoratePopulationCountfromGeneralElection < ActiveRecord::Migration[8.1]
  def change 
    remove_column :general_elections, :electorate_population_count, :integer
  end
end
