class Country < ApplicationRecord
  
  def boundary_sets
    BoundarySet.all.where( "country_id = ?", self ).order( 'start_on DESC' )
  end
  
  def current_constituencies
    ConstituencyArea.find_by_sql(
      "
        SELECT ca.*
        FROM constituency_areas ca, boundary_sets bs
        WHERE ca.boundary_set_id = bs.id
        AND ca.country_id = #{self.id}
        AND bs.end_on IS NULL
        ORDER BY ca.name
      "
    )
  end
  
  def current_english_regions
    EnglishRegion.find_by_sql(
      "
        SELECT er.*
        FROM english_regions er, constituency_areas ca, boundary_sets bs
        WHERE er.country_id = #{self.id}
        AND er.id = ca.english_region_id
        AND ca.boundary_set_id = bs.id
        GROUP BY er.id
        ORDER BY er.name
      "
    )
  end
  
  def current_constituencies_in_region( english_region )
    ConstituencyArea.find_by_sql(
      "
        SELECT ca.*
        FROM constituency_areas ca, boundary_sets bs, english_regions er
        WHERE ca.boundary_set_id = bs.id
        AND ca.country_id = #{self.id}
        AND ca.english_region_id = #{english_region.id}
        AND bs.end_on IS NULL
        GROUP BY ca.id
        ORDER BY ca.name
      "
    )
  end
end
