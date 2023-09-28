class Candidacy < ApplicationRecord
  
  belongs_to :election
  
  belongs_to :candidate_gender, class_name: 'Gender', foreign_key: :candidate_gender_id
end
