class CreateGeneralElections < ActiveRecord::Migration[7.0]
  def change
    create_table :general_elections do |t|

      t.timestamps
    end
  end
end
