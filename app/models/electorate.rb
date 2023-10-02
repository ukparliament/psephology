class Electorate < ApplicationRecord
  
  belongs_to :election
  belongs_to :constituency_group
end
