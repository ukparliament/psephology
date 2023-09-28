class ConstituencyGroup < ApplicationRecord
  
  belongs_to :constituency_area, optional: true
end
