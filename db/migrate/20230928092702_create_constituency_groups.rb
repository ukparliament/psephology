class CreateConstituencyGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :constituency_groups do |t|

      t.timestamps
    end
  end
end
