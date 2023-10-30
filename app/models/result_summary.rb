class ResultSummary < ApplicationRecord
  
  def from_political_party
    PoliticalParty.find( self.from_political_party_id )
  end
  
  def to_political_party
    PoliticalParty.find( self.to_political_party_id )
  end
end
