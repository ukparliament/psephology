class Election < ApplicationRecord
  
  belongs_to :constituency_group
  belongs_to :electorate, optional: true
  belongs_to :general_election, optional: true
  belongs_to :result_summary, optional: true
  
  def winning_candidacy
    Candidacy.all.where( "election_id = ?", self ).where( 'is_winning_candidacy IS TRUE' ).first
  end
  
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
          main_party.abbreviation AS main_party_abbreviation,
          adjunct_party.id AS adjunct_party_id, 
          adjunct_party.name AS adjunct_party_name,
          adjunct_party.abbreviation AS adjunct_party_abbreviation,
          candidate_gender.id AS candidate_gender_id,
          candidate_gender.gender AS candidate_gender_gender
        FROM candidacies c
        
        LEFT JOIN (
          SELECT pp.id AS id, pp.name AS name, pp.abbreviation AS abbreviation, c.candidacy_id AS candidacy_id
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
        
        RIGHT JOIN (
          SELECT g.*
          FROM genders g
        ) candidate_gender
        ON candidate_gender.id = c.candidate_gender_id
        
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
          main_party.abbreviation AS main_party_abbreviation,
          adjunct_party.id AS adjunct_party_id, 
          adjunct_party.name AS adjunct_party_name,
          adjunct_party.abbreviation AS adjunct_party_abbreviation,
          candidate_gender.id AS candidate_gender_id,
          candidate_gender.gender AS candidate_gender_gender
        FROM candidacies c
        
        LEFT JOIN (
          SELECT pp.id AS id, pp.name AS name, pp.abbreviation AS abbreviation, c.candidacy_id AS candidacy_id
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
        
        RIGHT JOIN (
          SELECT g.*
          FROM genders g
        ) candidate_gender
        ON candidate_gender.id = c.candidate_gender_id
        
        WHERE c.election_id = #{self.id}
        ORDER BY c.vote_count desc
      "
    )
  end
  
  # ## A method to determine if an election has been held.
  def has_been_held?
    
    # We base this logic on whether the election has a declaration time.
    has_been_held = false
    has_been_held = true if self.declaration_at
    has_been_held
  end
  
  def winning_candidate_name
    self.winning_candidate_given_name + ' ' + self.winning_candidate_family_name 
  end
  
  def turnout
    turnout = self.valid_vote_count.to_f / self.electorate_population_count.to_f
    turnout = turnout * 100
    turnout = turnout.round( 1 )
  end
  
  def candidate_polling_name
    candidate_polling_name = self.winning_candidacy_candidate_family_name.upcase
    candidate_polling_name += ', '
    candidate_polling_name += self.winning_candidacy_candidate_given_name
    candidate_polling_name
  end
  
  def political_party_candidacy( political_party )
    Candidacy.find_by_sql(
      "
        SELECT can.* 
        FROM candidacies can, certifications cert
        WHERE can.election_id = #{self.id}
        AND can.id = cert.candidacy_id
        AND cert.political_party_id = #{political_party.id}
        ORDER BY can.vote_count DESC
      "
    ).first
  end
  
  def winning_candidacy_party_names
    winning_candidacy_party_names = self.winning_candidacy_party_name
    winning_candidacy_party_names += ' / ' + self.winning_candidacy_adjunct_party_name if self.winning_candidacy_adjunct_party_name
    winning_candidacy_party_names
  end
  
  def boundary_set
    BoundarySet.find_by_sql(
      "
        SELECT bs.*
        FROM boundary_sets bs, constituency_areas ca, constituency_groups cg, elections e
        WHERE bs.id = ca.boundary_set_id
        AND cg.constituency_area_id = ca.id
        AND cg.id = e.constituency_group_id
        AND e.id = #{self.id}
      "
    ).first
  end
end
