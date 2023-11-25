class BoundarySetGeneralElectionPartyPerformance < ApplicationRecord
  
  belongs_to :general_election
  belongs_to :political_party
  belongs_to :boundary_set
end
