class Candidacy < ApplicationRecord
  
  belongs_to :election
  belongs_to :candidate_gender, class_name: 'Gender', foreign_key: :candidate_gender_id
  
  def candidate_polling_name
    candidate_polling_name = self.candidate_family_name.upcase
    candidate_polling_name += ', '
    candidate_polling_name += self.candidate_given_name
    candidate_polling_name
  end
end
