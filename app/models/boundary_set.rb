class BoundarySet < ApplicationRecord
  
  belongs_to :country
  
  def display_title
    display_title = self.country_name
    display_title += ' (' + self.start_on.strftime( $DATE_DISPLAY_FORMAT ) + ' - ' 
    display_title += self.end_on.strftime( $DATE_DISPLAY_FORMAT ) if self.end_on
    display_title += ')'
    display_title
  end
  
  def display_dates
    display_dates = self.start_on.strftime( $DATE_DISPLAY_FORMAT ) + ' - ' 
    display_dates += self.end_on.strftime( $DATE_DISPLAY_FORMAT ) if self.end_on
    display_dates
  end
  
  def general_elections
    GeneralElection.find_by_sql(
      "
        SELECT ge.*
        FROM general_elections ge, elections e, constituency_groups cg, constituency_areas ca
        WHERE e.general_election_id = ge.id
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.boundary_set_id = #{self.id}
        GROUP BY ge.id
        ORDER BY ge.polling_on DESC
      "
    )
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
  
  def elections
    Election.find_by_sql(
      "
        SELECT 
          e.*,
          ( cast(e.majority as decimal) / e.valid_vote_count ) AS majority_percentage,
          boundary_set.constituency_area_id AS constituency_area_id,
          winning_candidacy.is_standing_as_commons_speaker AS winning_candidacy_standing_as_commons_speaker,
          winning_candidacy.is_standing_as_independent AS  winning_candidacy_standing_as_independent,
          winning_candidacy_party.party_name AS winning_candidacy_party_name,
          winning_candidacy_party.party_abbreviation AS winning_candidacy_party_abbreviation,
          winning_candidacy_adjunct_party.party_name AS winning_candidacy_adjunct_party_name,
          winning_candidacy_adjunct_party.party_abbreviation AS winning_candidacy_adjunct_party_abbreviation
        FROM elections e
        
        INNER JOIN (
          SELECT cg.id AS constituency_group_id, ca.id AS constituency_area_id
          FROM constituency_groups cg, constituency_areas ca
          WHERE cg.constituency_area_id = ca.id
          AND ca.boundary_set_id =  #{self.id}
        ) AS boundary_set
        ON boundary_set.constituency_group_id = e.constituency_group_id
        
        INNER JOIN (
          SELECT c.*
          FROM candidacies c
          WHERE c.is_winning_candidacy IS TRUE
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
        
        LEFT JOIN (
          SELECT can.election_id AS election_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation
          FROM candidacies can, certifications cert, political_parties pp
          WHERE can.is_winning_candidacy IS TRUE
          AND can.id = cert.candidacy_id
          AND cert.adjunct_to_certification_id IS NULL
          AND cert.political_party_id = pp.id
        ) winning_candidacy_party
        ON winning_candidacy_party.election_id = e.id
        
        LEFT JOIN (
          SELECT can.election_id AS election_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation
          FROM candidacies can, certifications cert, political_parties pp
          WHERE can.is_winning_candidacy IS TRUE
          AND can.id = cert.candidacy_id
          AND cert.adjunct_to_certification_id IS NOT NULL
          AND cert.political_party_id = pp.id
        ) winning_candidacy_adjunct_party
        ON winning_candidacy_adjunct_party.election_id = e.id
        
        WHERE e.general_election_id IS NOT NULL
        ORDER BY e.polling_on
      "
    )
  end
  
  def elections_in_general_elections
    Election.find_by_sql(
      "
        SELECT
          e.*,
          ( cast(e.majority as decimal) / e.valid_vote_count ) AS majority_percentage,
          electorate.population_count AS electorate_population_count,
          constituency_area.constituency_area_name AS constituency_area_name,
          constituency_area.constituency_area_id AS constituency_area_id,
          general_election.polling_on AS general_election_polling_on,
          winning_candidacy.is_standing_as_commons_speaker AS winning_candidacy_standing_as_commons_speaker,
          winning_candidacy.is_standing_as_independent AS  winning_candidacy_standing_as_independent,
          winning_candidacy_party.party_name AS winning_candidacy_party_name,
          winning_candidacy_party.party_abbreviation AS winning_candidacy_party_abbreviation,
          winning_candidacy_adjunct_party.party_abbreviation AS winning_candidacy_adjunct_party_abbreviation,
          winning_candidacy_adjunct_party.party_name AS winning_candidacy_adjunct_party_name
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM electorates
        ) AS electorate
        ON electorate.id = e.electorate_id
        
        INNER JOIN ( 
          SELECT cg.id AS constituency_group_id, ca.id AS constituency_area_id, ca.name AS constituency_area_name
          FROM constituency_groups cg, constituency_areas ca
          WHERE cg.constituency_area_id = ca.id AND ca.boundary_set_id = #{self.id}
        ) constituency_area
        ON constituency_area.constituency_group_id = e.constituency_group_id
        
        INNER JOIN (
          SELECT *
          FROM general_elections
        ) general_election
        ON general_election.id = e.general_election_id
        
        INNER JOIN (
          SELECT c.*
          FROM candidacies c
          WHERE c.is_winning_candidacy IS TRUE
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
        
        LEFT JOIN (
          SELECT can.election_id AS election_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation
          FROM candidacies can, certifications cert, political_parties pp
          WHERE can.is_winning_candidacy IS TRUE
          AND can.id = cert.candidacy_id
          AND cert.adjunct_to_certification_id IS NULL
          AND cert.political_party_id = pp.id
        ) winning_candidacy_party
        ON winning_candidacy_party.election_id = e.id
        
        LEFT JOIN (
          SELECT can.election_id AS election_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation
          FROM candidacies can, certifications cert, political_parties pp
          WHERE can.is_winning_candidacy IS TRUE
          AND can.id = cert.candidacy_id
          AND cert.adjunct_to_certification_id IS NOT NULL
          AND cert.political_party_id = pp.id
        ) winning_candidacy_adjunct_party
        ON winning_candidacy_adjunct_party.election_id = e.id
        
        ORDER BY constituency_area_name, general_election_polling_on
        
      "
    )
  end
  
  def establishing_legislation
    LegislationItem.find_by_sql(
      "
        SELECT li.*
        FROM legislation_items li, boundary_set_legislation_items bsli
        WHERE li.id = bsli.legislation_item_id
        AND bsli.boundary_set_id = #{self.id}
        ORDER BY li.title
      "
    )
  end
  
  def nodes
    Node.find_by_sql(
      "
        SELECT *
        FROM nodes
        WHERE boundary_set_id = #{self.id}
      "
    )
  end
  
  def edges
    Edge.find_by_sql(
      "
        SELECT e.*
        FROM edges e, nodes n
        WHERE ( e.from_node_id = n.id OR e.to_node_id = n.id )
        AND n.boundary_set_id = #{self.id}
        GROUP BY e.id
      "
    )
  end
end
