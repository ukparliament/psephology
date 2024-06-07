class ResultSummary < ApplicationRecord
  
  def from_political_party
    PoliticalParty.find( self.from_political_party_id )
  end
  
  def to_political_party
    PoliticalParty.find( self.to_political_party_id )
  end
  
  def is_gain?
    is_gain = false
    is_gain = true if self.short_summary.include?( ' gain from ' )
    is_gain
  end
end
