# == Schema Information
#
# Table name: result_summaries
#
#  id                      :integer          not null, primary key
#  is_from_commons_speaker :boolean          default(FALSE)
#  is_from_independent     :boolean          default(FALSE)
#  is_to_commons_speaker   :boolean          default(FALSE)
#  is_to_independent       :boolean          default(FALSE)
#  short_summary           :string(50)       not null
#  summary                 :string(255)
#  from_political_party_id :integer
#  to_political_party_id   :integer
#
# Foreign Keys
#
#  fk_from_political_party  (from_political_party_id => political_parties.id)
#  fk_to_political_party    (to_political_party_id => political_parties.id)
#
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
