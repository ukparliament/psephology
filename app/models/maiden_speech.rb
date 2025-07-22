# == Schema Information
#
# Table name: maiden_speeches
#
#  id                    :integer          not null, primary key
#  hansard_reference     :string(255)      not null
#  hansard_url           :string(255)      not null
#  made_on               :date             not null
#  session_number        :integer          not null
#  constituency_group_id :integer          not null
#  member_id             :integer          not null
#  parliament_period_id  :integer          not null
#
# Foreign Keys
#
#  fk_constituency_group  (constituency_group_id => constituency_groups.id)
#  fk_member              (member_id => members.id)
#  fk_parliament_period   (parliament_period_id => parliament_periods.id)
#
class MaidenSpeech < ApplicationRecord

  belongs_to :member
  belongs_to :constituency_group
  belongs_to :parliament_period
  belongs_to :main_political_party, :class_name => 'PoliticalParty', optional: true
  belongs_to :adjunct_political_party, :class_name => 'PoliticalParty', optional: true
end
