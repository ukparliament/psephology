class Election < ApplicationRecord
  
  belongs_to :constituency_group
  belongs_to :general_election, optional: true
  
  def by_election_display_title
    display_title = self.constituency_group_name
    display_title += ' - ' + self.polling_on.strftime( $DATE_DISPLAY_FORMAT )
    display_title
  end
  
  def candidacies
    Candidacy.find_by_sql(
      "
        SELECT c.*
        FROM candidacies c
        WHERE c.election_id = #{self.id}
        ORDER BY c.candidate_family_name, c.candidate_given_name
      "
    )
  end
  
  def results
    Candidacy.find_by_sql(
      "
        SELECT c.*
        FROM candidacies c
        WHERE c.election_id = #{self.id}
        ORDER BY c.vote_count desc
      "
    )
  end
end
