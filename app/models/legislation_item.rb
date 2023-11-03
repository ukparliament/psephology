class LegislationItem < ApplicationRecord
  
  belongs_to :legislation_type
  
  def enabling_legislation
    LegislationItem.find_by_sql(
      "
        SELECT li.*
        FROM legislation_items li, enablings e
        WHERE e.enabling_legislation_id = li.id
        AND e.enabled_legislation_id = #{self.id}
        ORDER BY statute_book_on DESC
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
        ORDER BY statute_book_on DESC
      "
    )
  end
end
