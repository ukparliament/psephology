# == Schema Information
#
# Table name: certifications
#
#  id                          :integer          not null, primary key
#  adjunct_to_certification_id :integer
#  candidacy_id                :integer          not null
#  political_party_id          :integer          not null
#
# Indexes
#
#  index_certifications_on_candidacy_id        (candidacy_id)
#  index_certifications_on_political_party_id  (political_party_id)
#
# Foreign Keys
#
#  fk_adjunct_to_certification  (adjunct_to_certification_id => certifications.id)
#  fk_candidacy                 (candidacy_id => candidacies.id)
#  fk_political_party           (political_party_id => political_parties.id)
#  fk_rails_...                 (candidacy_id => candidacies.id) ON DELETE => cascade
#
class Certification < ApplicationRecord
  
  belongs_to :candidacy
  belongs_to :political_party
end
