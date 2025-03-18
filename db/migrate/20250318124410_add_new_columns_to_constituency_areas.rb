class AddNewColumnsToConstituencyAreas < ActiveRecord::Migration[8.0]
  def change
    add_column :constituency_areas, :mnis_id, :int
    add_column :constituency_areas, :is_geographic_code_issued_by_ons, :boolean, default: true
  end
end
