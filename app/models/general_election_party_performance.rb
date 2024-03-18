class GeneralElectionPartyPerformance < ApplicationRecord
  
  belongs_to :general_election
  belongs_to :political_party
  
  def vote_share
    ( ( self.cumulative_vote_count.to_f / self.general_election_valid_vote_count.to_f ) * 100 ).round( 1 )
  end
  
  def party_class_name
    party_class_name = 'party'
    party_class_name += ' ' + self.party_electoral_commission_id if self.party_electoral_commission_id
    party_class_name
  end
end
