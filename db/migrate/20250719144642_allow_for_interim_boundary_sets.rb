class AllowForInterimBoundarySets < ActiveRecord::Migration[8.0]
  def change
    add_reference :boundary_sets, :parent_boundary_set, foreign_key: { to_table: :boundary_sets }
    add_column :boundary_sets, :column_description, :string
    add_reference :constituency_group_sets, :parent_constituency_group_set, foreign_key: { to_table: :constituency_group_sets }
    add_column :constituency_group_sets, :column_description, :string
  end
end
