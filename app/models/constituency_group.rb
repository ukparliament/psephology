# == Schema Information
#
# Table name: constituency_groups
#
#  id                        :integer          not null, primary key
#  name                      :string(255)      not null
#  constituency_area_id      :integer
#  constituency_group_set_id :integer
#
# Indexes
#
#  index_constituency_groups_on_constituency_area_id       (constituency_area_id)
#  index_constituency_groups_on_constituency_group_set_id  (constituency_group_set_id)
#
# Foreign Keys
#
#  fk_constituency_area       (constituency_area_id => constituency_areas.id)
#  fk_constituency_group_set  (constituency_group_set_id => constituency_group_sets.id)
#
class ConstituencyGroup < ApplicationRecord
  
  belongs_to :constituency_area, optional: true
  belongs_to :constituency_group_set, optional: true # Optional here and in the database because this is populated later.
  
  def boundary_set
    BoundarySet.find_by_sql([
      "
        SELECT bs.*
        FROM boundary_sets bs, constituency_areas ca, constituency_groups cg
        WHERE bs.id = ca.boundary_set_id
        AND ca.id = cg.constituency_area_id
        AND cg.id = ?
      ", id
    ]).first
  end
end
