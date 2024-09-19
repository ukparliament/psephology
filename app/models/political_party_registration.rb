class PoliticalPartyRegistration < ApplicationRecord
  
  belongs_to :political_party
  belongs_to :country
end
