# == Schema Information
#
# Table name: constituency_group_sets
#
#  id                               :integer          not null, primary key
#  description                      :string(255)
#  end_on                           :date
#  start_on                         :date
#  country_id                       :integer          not null
#  parent_constituency_group_set_id :integer
#
# Indexes
#
#  index_constituency_group_sets_on_country_id  (country_id)
#
# Foreign Keys
#
#  fk_country                        (country_id => countries.id)
#  fk_parent_constituency_group_set  (parent_constituency_group_set_id => constituency_group_sets.id)
#
class ConstituencyGroupSet < ApplicationRecord
  
  belongs_to :country
end
