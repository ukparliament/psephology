class Country < ApplicationRecord
  
  def boundary_sets
    BoundarySet.all.where( "country_id = ?", self ).order( 'start_on DESC' )
  end
end
