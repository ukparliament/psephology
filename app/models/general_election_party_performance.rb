# == Schema Information
#
# Table name: general_election_party_performances
#
#  id                           :integer          not null, primary key
#  constituency_contested_count :integer          not null
#  constituency_won_count       :integer          not null
#  cumulative_valid_vote_count  :integer          not null
#  cumulative_vote_count        :integer          not null
#  general_election_id          :integer          not null
#  political_party_id           :integer          not null
#
# Foreign Keys
#
#  fk_general_election  (general_election_id => general_elections.id)
#  fk_political_party   (political_party_id => political_parties.id)
#  fk_rails_...         (general_election_id => general_elections.id) ON DELETE => cascade
#
class GeneralElectionPartyPerformance < ApplicationRecord
  
  belongs_to :general_election
  belongs_to :political_party
  
  def vote_share
    ( ( self.cumulative_vote_count.to_f / self.general_election_valid_vote_count.to_f ) * 100 ).round( 1 )
  end
  
  def party_class_name
    party_class_name = 'party'
    party_class_name += ' party-' + self.party_mnis_id.to_s if self.party_mnis_id
    party_class_name
  end
end
