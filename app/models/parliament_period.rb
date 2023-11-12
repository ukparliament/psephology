class ParliamentPeriod < ApplicationRecord
  
  def display_dates
    display_dates = self.summoned_on.strftime( $DATE_DISPLAY_FORMAT )
    display_dates += ' - '
    display_dates += self.dissolved_on.strftime( $DATE_DISPLAY_FORMAT ) if self.dissolved_on
    display_dates
  end
end
