# == Schema Information
#
# Table name: candidacies
#
#  id                               :integer          not null, primary key
#  candidate_family_name            :string(255)
#  candidate_given_name             :string(255)
#  candidate_is_former_mp           :boolean          default(FALSE)
#  candidate_is_sitting_mp          :boolean          default(FALSE)
#  democracy_club_person_identifier :integer
#  is_notional                      :boolean          default(FALSE)
#  is_standing_as_commons_speaker   :boolean          default(FALSE)
#  is_standing_as_independent       :boolean          default(FALSE)
#  is_winning_candidacy             :boolean          default(FALSE)
#  result_position                  :integer
#  vote_change                      :float(24)
#  vote_count                       :integer
#  vote_share                       :float(24)
#  candidate_gender_id              :integer
#  election_id                      :integer          not null
#  member_id                        :integer
#
# Indexes
#
#  index_candidacies_on_candidate_gender_id  (candidate_gender_id)
#  index_candidacies_on_election_id          (election_id)
#  index_candidacies_on_member_id            (member_id)
#
# Foreign Keys
#
#  fk_candidate_gender  (candidate_gender_id => genders.id)
#  fk_election          (election_id => elections.id)
#  fk_member            (member_id => members.id)
#  fk_rails_...         (election_id => elections.id) ON DELETE => cascade
#
class Candidacy < ApplicationRecord
  
  belongs_to :election
  belongs_to :candidate_gender, class_name: 'Gender', foreign_key: :candidate_gender_id, optional: true
  belongs_to :member, optional: true
  has_many :certifications
  
  def adjunct_certifications
    Certification.where( "candidacy_id = ?", self.id ).where( "adjunct_to_certification_id IS NOT NULL" )
  end
  
  def main_certifications
    Certification.where( "candidacy_id = ?", self.id ).where( "adjunct_to_certification_id IS NULL" )
  end
  
  def candidate_polling_name
    candidate_polling_name = self.candidate_family_name.upcase
    candidate_polling_name += ', '
    candidate_polling_name += self.candidate_given_name
    candidate_polling_name
  end
  
  def candidate_display_name
    candidate_display_name = self.candidate_given_name
    candidate_display_name += ' '
    candidate_display_name += self.candidate_family_name
    candidate_display_name
  end
  
  def main_party_listing_abbreviation
    main_party_listing_abbreviation = ''
    if self.is_standing_as_commons_speaker == true
      main_party_listing_abbreviation = 'Spk'
    elsif self.is_standing_as_independent == true
      main_party_listing_abbreviation = 'Ind'
    else
      main_party_listing_abbreviation = self.main_party_abbreviation
    end
    main_party_listing_abbreviation
  end
  
  def lost_deposit?
    lost_deposit = false
    if ( self.vote_share.to_f * 100 ).round( 1 ) < 5
      lost_deposit = true
    end
    lost_deposit
  end
  
  def lost_deposit_text
    lost_deposit_text = 'No'
    if self.lost_deposit?
      lost_deposit_text = 'Yes'
    end
    lost_deposit_text
  end
  
  def party_class_name
    party_class_name = 'party'
    if self.main_party_mnis_id
      party_class_name += ' party-' + self.main_party_mnis_id.to_s
    end
    party_class_name
  end
end
