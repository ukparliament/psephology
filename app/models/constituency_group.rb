class ConstituencyGroup < ApplicationRecord
  
  belongs_to :constituency_area, optional: true
  belongs_to :constituency_group_set, optional: true # Optional here and in the database because this is populated later.
  
  def boundary_set
    BoundarySet.find_by_sql(
      "
        SELECT bs.*
        FROM boundary_sets bs, constituency_areas ca, constituency_groups cg
        WHERE bs.id = ca.boundary_set_id
        AND ca.id = cg.constituency_area_id
        AND cg.id = #{self.id}
      "
    ).first
  end
end
