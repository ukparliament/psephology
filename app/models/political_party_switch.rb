class PoliticalPartySwitch < ApplicationRecord
  
  belongs_to :general_election
  belongs_to :boundary_set
end
