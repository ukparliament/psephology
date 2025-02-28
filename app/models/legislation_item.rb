# == Schema Information
#
# Table name: legislation_items
#
#  id                  :integer          not null, primary key
#  made_on             :date
#  royal_assent_on     :date
#  statute_book_on     :date             not null
#  title               :string(255)      not null
#  uri                 :string(255)
#  url_key             :string(20)       not null
#  legislation_type_id :integer          not null
#
# Indexes
#
#  index_legislation_items_on_legislation_type_id  (legislation_type_id)
#
# Foreign Keys
#
#  fk_legislation_type  (legislation_type_id => legislation_types.id)
#
class LegislationItem < ApplicationRecord
  
  belongs_to :legislation_type
  
  def enabling_legislation
    LegislationItem.find_by_sql([
      "
        SELECT li.*
        FROM legislation_items li, enablings e
        WHERE e.enabling_legislation_id = li.id
        AND e.enabled_legislation_id = ?
        ORDER BY statute_book_on DESC, title
      ", id
    ])
  end
  
  def enabled_legislation
    LegislationItem.find_by_sql([
      "
        SELECT li.*
        FROM legislation_items li, enablings e
        WHERE e.enabled_legislation_id = li.id
        AND e.enabling_legislation_id = ?
        ORDER BY statute_book_on DESC, title
      ", id
    ])
  end
  
  def boundary_sets
    BoundarySet.find_by_sql([
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, boundary_set_legislation_items bsli, countries c
        WHERE bs.id = bsli.boundary_set_id
        AND bsli.legislation_item_id = ?
        AND bs.country_id = c.id
        ORDER BY bs.start_on DESC, country_name
      ", id
    ])
  end
end
