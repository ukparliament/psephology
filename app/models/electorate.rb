# == Schema Information
#
# Table name: electorates
#
#  id                    :integer          not null, primary key
#  population_count      :integer          not null
#  constituency_group_id :integer          not null
#
# Indexes
#
#  index_electorates_on_constituency_group_id  (constituency_group_id)
#
# Foreign Keys
#
#  fk_constituency_group  (constituency_group_id => constituency_groups.id)
#
class Electorate < ApplicationRecord
  
  belongs_to :constituency_group
end
