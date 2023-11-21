class ConstituencyGroupSetLegislationItem < ApplicationRecord
  
  belongs_to :constituency_group_set
  belongs_to :legislation_item
end
