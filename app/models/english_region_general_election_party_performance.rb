class EnglishRegionGeneralElectionPartyPerformance < ApplicationRecord
  
  belongs_to :general_election
  belongs_to :political_party
  belongs_to :english_region
  
  def vote_share( valid_vote_count )
    ( ( self.cumulative_vote_count.to_f / valid_vote_count.to_f ) * 100 ).round( 1 )
  end
end