class ConstituencyAreaOverlap < ApplicationRecord
  
  def constituency_area_name_with_dates
    name_with_dates = self.constituency_area_name
    if self.start_on
      name_with_dates += ' (' + self.start_on.strftime( $DATE_DISPLAY_FORMAT ) + ' - '
    else
      name_with_dates += ' (start date dependent on next dissolution'
    end
    #name_with_dates += ' (' + self.start_on.strftime( $DATE_DISPLAY_FORMAT ) + ' - '
    name_with_dates += self.end_on.strftime( $DATE_DISPLAY_FORMAT ) if self.end_on
    name_with_dates += ')'
    name_with_dates
  end
  
  def constituency_area_name_with_years
    name_with_dates = self.constituency_area_name
    if self.start_on
      name_with_dates += ' (' + self.start_on.strftime( '%Y' ) + ' - '
    else
      name_with_dates += ' (start date dependent on next dissolution'
    end
    name_with_dates += self.end_on.strftime( '%Y' ) if self.end_on
    name_with_dates += ')'
    name_with_dates
  end
  
  def from_constituency_area
    ConstituencyArea.all.where( "id = ?", self.from_constituency_area_id ).first
  end
  
  def to_constituency_area
    ConstituencyArea.all.where( "id = ?", self.to_constituency_area_id ).first
  end
end
