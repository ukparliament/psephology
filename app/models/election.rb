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
        SELECT c.*, 
          main_party.id AS main_party_id, 
          main_party.name AS main_party_name,
          adjunct_party.id AS adjunct_party_id, 
          adjunct_party.name AS adjunct_party_name
        FROM candidacies c
        
        LEFT JOIN (
          SELECT pp.id AS id, pp.name AS name, c.candidacy_id AS candidacy_id
          FROM political_parties pp, certifications c
          WHERE c.political_party_id = pp.id
          AND c.adjunct_to_certification_id IS NULL
        ) main_party
        ON main_party.candidacy_id = c.id
        
        LEFT JOIN (
          SELECT pp.*, c.candidacy_id AS candidacy_id
          FROM political_parties pp, certifications c
          WHERE c.political_party_id = pp.id
          AND c.adjunct_to_certification_id IS NOT NULL
        ) adjunct_party
        ON adjunct_party.candidacy_id = c.id
        
        WHERE c.election_id = #{self.id}
        ORDER BY c.candidate_family_name, c.candidate_given_name
      "
    )
  end
  
  def results
    Candidacy.find_by_sql(
      "
        SELECT c.*, 
          main_party.id AS main_party_id, 
          main_party.name AS main_party_name,
          adjunct_party.id AS adjunct_party_id, 
          adjunct_party.name AS adjunct_party_name
        FROM candidacies c
        
        LEFT JOIN (
          SELECT pp.id AS id, pp.name AS name, c.candidacy_id AS candidacy_id
          FROM political_parties pp, certifications c
          WHERE c.political_party_id = pp.id
          AND c.adjunct_to_certification_id IS NULL
        ) main_party
        ON main_party.candidacy_id = c.id
        
        LEFT JOIN (
          SELECT pp.*, c.candidacy_id AS candidacy_id
          FROM political_parties pp, certifications c
          WHERE c.political_party_id = pp.id
          AND c.adjunct_to_certification_id IS NOT NULL
        ) adjunct_party
        ON adjunct_party.candidacy_id = c.id
        
        WHERE c.election_id = #{self.id}
        ORDER BY c.vote_count desc
      "
    )
  end
end
