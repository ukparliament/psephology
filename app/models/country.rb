class Country < ApplicationRecord
  
  def parent_country
    parent_country = nil
    if self.parent_country_id
      parent_country = Country.find_by_sql(
        "
          SELECT *
          FROM countries
          WHERE id = #{self.parent_country_id};
        "
      ).first
    end
    parent_country
  end
  
  def child_countries
    Country.find_by_sql(
      "
        SELECT *
        FROM countries
        WHERE parent_country_id = #{self.id}
        ORDER BY name;
      "
    )
    
  end
  
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
        AND bs.start_on IS NOT NULL
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
        AND bs.start_on IS NOT NULL
        AND bs.end_on IS NULL
        GROUP BY ca.id
        ORDER BY ca.name
      "
    )
  end
  
  def countries_having_first_elections_in_boundary_set_for_general_election( general_election )
    Country.find_by_sql(
      "
        SELECT c.*
        FROM countries c, boundary_sets bs, general_election_in_boundary_sets gebs
        WHERE c.id = bs.country_id
        AND bs.id = gebs.boundary_set_id
        AND gebs.general_election_id = #{general_election.id}
        AND gebs.ordinality = 1
        AND (
          c.id = #{self.id}
          OR
          c.parent_country_id = #{self.id} 
        )
        ORDER BY c.name
      "
    )
  end
end
