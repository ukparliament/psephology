class Candidacy < ApplicationRecord
  
  belongs_to :election
  belongs_to :candidate_gender, class_name: 'Gender', foreign_key: :candidate_gender_id
  
  def candidate_polling_name
    candidate_polling_name = self.candidate_family_name.upcase
    candidate_polling_name += ', '
    candidate_polling_name += self.candidate_given_name
    candidate_polling_name
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
end
