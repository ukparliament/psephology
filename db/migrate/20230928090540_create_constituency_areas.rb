class CreateConstituencyAreas < ActiveRecord::Migration[7.0]
  def change
    create_table :constituency_areas do |t|

      t.timestamps
    end
  end
end
