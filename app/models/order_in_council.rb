class OrderInCouncil < ApplicationRecord
  self.table_name = "orders_in_council"
  
  def boundary_sets
    BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, countries c
        WHERE bs.order_in_council_id = #{self.id}
        AND bs.country_id = c.id
      "
    )
  end
end
