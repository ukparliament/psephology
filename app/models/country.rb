# == Schema Information
#
# Table name: countries
#
#  id                :integer          not null, primary key
#  geographic_code   :string(255)
#  name              :string(255)      not null
#  ons_linked        :boolean          default(FALSE)
#  parent_country_id :integer
#
# Foreign Keys
#
#  fk_parent_country  (parent_country_id => countries.id)
#
class Country < ApplicationRecord
  
  def parent_country
    parent_country = nil
    if self.parent_country_id
      parent_country = Country.find_by_sql([
        "
          SELECT *
          FROM countries
          WHERE id = ?;
        ", parent_country_id
      ]).first
    end
    parent_country
  end
  
  def child_countries
    Country.find_by_sql([
      "
        SELECT *
        FROM countries
        WHERE parent_country_id = ?
        ORDER BY name;
      ", id
    ])
    
  end
  
  def boundary_sets
    BoundarySet.find_by_sql ([
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, countries c
        WHERE bs.country_id = c.id
        AND c.id = ?
        ORDER BY bs.start_on DESC
      ", id
    ])
  end
  
  def current_constituencies
    ConstituencyArea.find_by_sql([
      "
        SELECT ca.*
        FROM constituency_areas ca, boundary_sets bs
        WHERE ca.boundary_set_id = bs.id
        AND ca.country_id = ?
        AND bs.start_on IS NOT NULL
        AND bs.end_on IS NULL
        ORDER BY ca.name
      ", id
    ])
  end
  
  def current_english_regions
    EnglishRegion.find_by_sql([
      "
        SELECT er.*
        FROM english_regions er, constituency_areas ca, boundary_sets bs
        WHERE er.country_id = ?
        AND er.id = ca.english_region_id
        AND ca.boundary_set_id = bs.id
        GROUP BY er.id
        ORDER BY er.name
      ", id
    ])
  end
  
  def current_constituencies_in_region( english_region )
    ConstituencyArea.find_by_sql([
      "
        SELECT ca.*
        FROM constituency_areas ca, boundary_sets bs, english_regions er
        WHERE ca.boundary_set_id = bs.id
        AND ca.country_id = :id
        AND ca.english_region_id = :english_region_id
        AND bs.start_on IS NOT NULL
        AND bs.end_on IS NULL
        GROUP BY ca.id
        ORDER BY ca.name
      ", id: id, english_region_id: english_region.id
    ])
  end
end
