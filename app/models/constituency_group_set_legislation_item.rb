# == Schema Information
#
# Table name: constituency_group_set_legislation_items
#
#  id                        :integer          not null, primary key
#  constituency_group_set_id :integer          not null
#  legislation_item_id       :integer          not null
#
# Foreign Keys
#
#  fk_constituency_group_set  (constituency_group_set_id => constituency_group_sets.id)
#  fk_legislation_item        (legislation_item_id => legislation_items.id)
#
class ConstituencyGroupSetLegislationItem < ApplicationRecord
  
  belongs_to :constituency_group_set
  belongs_to :legislation_item
end
