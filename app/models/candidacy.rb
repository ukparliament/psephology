class Candidacy < ApplicationRecord
  
  belongs_to :election
  belongs_to :candidate_gender, class_name: 'Gender', foreign_key: :candidate_gender_id, optional: true
  belongs_to :member, optional: true
  
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
