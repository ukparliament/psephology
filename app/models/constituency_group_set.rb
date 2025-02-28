# == Schema Information
#
# Table name: constituency_group_sets
#
#  id         :integer          not null, primary key
#  end_on     :date
#  start_on   :date
#  country_id :integer          not null
#
# Indexes
#
#  index_constituency_group_sets_on_country_id  (country_id)
#
# Foreign Keys
#
#  fk_country  (country_id => countries.id)
#
class ConstituencyGroupSet < ApplicationRecord
  
  belongs_to :country
end
