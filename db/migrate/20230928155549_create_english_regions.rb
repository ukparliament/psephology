class CreateEnglishRegions < ActiveRecord::Migration[7.0]
  def change
    create_table :english_regions do |t|

      t.timestamps
    end
  end
end
