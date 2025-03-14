# == Schema Information
#
# Table name: boundary_set_legislation_items
#
#  id                  :integer          not null, primary key
#  boundary_set_id     :integer          not null
#  legislation_item_id :integer          not null
#
# Indexes
#
#  index_boundary_set_legislation_items_on_boundary_set_id      (boundary_set_id)
#  index_boundary_set_legislation_items_on_legislation_item_id  (legislation_item_id)
#
# Foreign Keys
#
#  fk_boundary_set      (boundary_set_id => boundary_sets.id)
#  fk_legislation_item  (legislation_item_id => legislation_items.id)
#
class BoundarySetLegislationItem < ApplicationRecord
  
  belongs_to :boundary_set
  belongs_to :legislation_item
end
