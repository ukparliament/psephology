class ConstituencyArea < ApplicationRecord
  
  belongs_to :country
  belongs_to :english_region, optional: true
  belongs_to :constituency_area_type
  belongs_to :boundary_set, optional: true
  
  def name_with_dates
    name_with_dates = self.name
    name_with_dates += ' (' + self.start_on.strftime( $DATE_DISPLAY_FORMAT ) + ' - '
    name_with_dates += self.end_on.strftime( $DATE_DISPLAY_FORMAT ) if self.end_on
    name_with_dates += ')'
    name_with_dates
  end
end
