class CreateConstituencyAreaTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :constituency_area_types do |t|

      t.timestamps
    end
  end
end
