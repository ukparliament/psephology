class MaidenSpeech < ApplicationRecord

  belongs_to :member
  belongs_to :constituency_group
  belongs_to :parliament_period
  belongs_to :main_political_party, :class_name => 'PoliticalParty', optional: true
  belongs_to :adjunct_political_party, :class_name => 'PoliticalParty', optional: true
end
