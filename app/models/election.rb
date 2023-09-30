class Election < ApplicationRecord
  
  belongs_to :constituency_group
  belongs_to :general_election, optional: true
  
  def by_election_display_title
    display_title = self.constituency_group_name
    display_title += ' - ' + self.polling_on.strftime( $DATE_DISPLAY_FORMAT )
    display_title
  end
end
