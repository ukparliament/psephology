# == Schema Information
#
# Table name: english_region_general_election_party_performances
#
#  id                           :integer          not null, primary key
#  constituency_contested_count :integer          not null
#  constituency_won_count       :integer          not null
#  cumulative_vote_count        :integer          not null
#  english_region_id            :integer          not null
#  general_election_id          :integer          not null
#  political_party_id           :integer          not null
#
# Foreign Keys
#
#  fk_english_region    (english_region_id => english_regions.id)
#  fk_general_election  (general_election_id => general_elections.id)
#  fk_political_party   (political_party_id => political_parties.id)
#  fk_rails_...         (general_election_id => general_elections.id) ON DELETE => cascade
#
class EnglishRegionGeneralElectionPartyPerformance < ApplicationRecord
  
  belongs_to :general_election
  belongs_to :political_party
  belongs_to :english_region
  
  def vote_share( valid_vote_count )
    ( ( self.cumulative_vote_count.to_f / valid_vote_count.to_f ) * 100 ).round( 1 )
  end
  
  def party_class_name
    party_class_name = 'party'
    party_class_name += ' party-' + self.party_mnis_id.to_s if self.party_mnis_id
    party_class_name
  end
end
