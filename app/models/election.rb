class Election < ApplicationRecord
  
  belongs_to :constituency_group
  belongs_to :general_election, optional: true
end
