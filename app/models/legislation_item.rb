class LegislationItem < ApplicationRecord
  
  belongs_to :legislation_type
  
  def enabling_legislation
    LegislationItem.find_by_sql(
      "
        SELECT li.*
        FROM legislation_items li, enablings e
        WHERE e.enabling_legislation_id = li.id
        AND e.enabled_legislation_id = #{self.id}
        ORDER BY statute_book_on DESC, title
      "
    )
  end
  
  def enabled_legislation
    LegislationItem.find_by_sql(
      "
        SELECT li.*
        FROM legislation_items li, enablings e
        WHERE e.enabled_legislation_id = li.id
        AND e.enabling_legislation_id = #{self.id}
        ORDER BY statute_book_on DESC, title
      "
    )
  end
  
  def boundary_sets
    BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, boundary_set_legislation_items bsli, countries c
        WHERE bs.id = bsli.boundary_set_id
        AND bsli.legislation_item_id = #{self.id}
        AND bs.country_id = c.id
        ORDER BY bs.start_on DESC, country_name
      "
    )
  end
end
