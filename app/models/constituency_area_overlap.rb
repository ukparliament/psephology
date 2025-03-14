# == Schema Information
#
# Table name: constituency_area_overlaps
#
#  id                             :integer          not null, primary key
#  formed_from_whole_of           :boolean          default(FALSE)
#  forms_whole_of                 :boolean          default(FALSE)
#  from_constituency_geographical :float(24)        not null
#  from_constituency_population   :float(24)        not null
#  from_constituency_residential  :float(24)        not null
#  to_constituency_geographical   :float(24)        not null
#  to_constituency_population     :float(24)        not null
#  to_constituency_residential    :float(24)        not null
#  from_constituency_area_id      :integer          not null
#  to_constituency_area_id        :integer          not null
#
# Foreign Keys
#
#  fk_from_constituency_area  (from_constituency_area_id => constituency_areas.id)
#  fk_to_constituency_area    (to_constituency_area_id => constituency_areas.id)
#
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
