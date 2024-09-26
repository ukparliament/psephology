class ElectionListingItem
  
  attr_accessor :id
  attr_accessor :type
  attr_accessor :polling_on
  attr_accessor :parliament_period_number
  attr_accessor :parliament_period_summoned_on
  attr_accessor :parliament_period_dissolved_on
  attr_accessor :parliament_period_wikidata_id
  attr_accessor :parliament_period_london_gazette
  attr_accessor :parliament_period_id
  attr_accessor :constituency_group_name
  attr_accessor :constituency_area_geographic_code
  attr_accessor :constituency_area_type
  attr_accessor :constituency_area_id
  
  def parliament_period_heading
    parliament_period_heading = "#{self.parliament_period_number.ordinalize} Parliament (#{self.parliament_period_summoned_on.strftime( $DATE_DISPLAY_FORMAT )} -"
    parliament_period_heading += " #{self.parliament_period_dissolved_on.strftime( $DATE_DISPLAY_FORMAT )}" if self.parliament_period_dissolved_on
    parliament_period_heading += ")"
    parliament_period_heading
  end
end

