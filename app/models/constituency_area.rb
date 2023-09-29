class ConstituencyArea < ApplicationRecord
  
  belongs_to :country
  belongs_to :english_region, optional: true
  belongs_to :constituency_area_type
  belongs_to :boundary_set, optional: true
end
