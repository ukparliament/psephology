# == Schema Information
#
# Table name: political_party_registrations
#
#  id                                   :integer          not null, primary key
#  end_on                               :date
#  political_party_name_last_updated_on :date
#  start_on                             :date             not null
#  country_id                           :integer          not null
#  electoral_commission_id              :string(20)       not null
#  political_party_id                   :integer          not null
#
# Foreign Keys
#
#  fk_country            (country_id => countries.id)
#  fk_political_parties  (political_party_id => political_parties.id)
#
class PoliticalPartyRegistration < ApplicationRecord
  
  belongs_to :political_party
  belongs_to :country
end
