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
end
