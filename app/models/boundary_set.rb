class BoundarySet < ApplicationRecord
  
  belongs_to :country
  belongs_to :order_in_council
  
  def display_title
    display_title = self.country_name
    display_title += ' (' + self.start_on.strftime( $DATE_DISPLAY_FORMAT ) + ' - ' 
    display_title += self.end_on.strftime( $DATE_DISPLAY_FORMAT ) if self.end_on
    display_title += ')'
    display_title
  end
  
  def constituency_areas
    ConstituencyArea.find_by_sql(
      "
        SELECT *
        FROM constituency_areas
        WHERE boundary_set_id = #{self.id}
        ORDER BY name
      "
    )
  end
end
