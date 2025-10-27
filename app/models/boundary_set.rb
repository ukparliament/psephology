# == Schema Information
#
# Table name: boundary_sets
#
#  id                     :integer          not null, primary key
#  description            :string(255)
#  end_on                 :date
#  start_on               :date
#  country_id             :integer          not null
#  parent_boundary_set_id :integer
#
# Indexes
#
#  index_boundary_sets_on_country_id  (country_id)
#
# Foreign Keys
#
#  fk_country              (country_id => countries.id)
#  fk_parent_boundary_set  (parent_boundary_set_id => boundary_sets.id)
#
class BoundarySet < ApplicationRecord

  attr_accessor :child_boundary_sets
  
  belongs_to :country
  
  def display_title
    display_title = self.country_name
    if self.start_on
      display_title += ' (' + self.start_on.strftime( $DATE_DISPLAY_FORMAT ) + ' - '
    else
      display_title += ' (start date dependent on next dissolution'
    end
    display_title += self.end_on.strftime( $DATE_DISPLAY_FORMAT ) if self.end_on
    display_title += ')'
    display_title
  end
  
  def display_title_with_description
    display_title = self.country_name
    if self.start_on
      display_title += ' (' + self.start_on.strftime( $DATE_DISPLAY_FORMAT ) + ' - '
    else
      display_title += ' (start date dependent on next dissolution'
    end
    display_title += self.end_on.strftime( $DATE_DISPLAY_FORMAT ) if self.end_on
    display_title += ')'
    if self.description
      display_title += ' - '
      display_title += self.description
    end
    display_title
  end
  
  def display_dates
    display_dates = ''
    if self.start_on
      display_dates += self.start_on.strftime( $DATE_DISPLAY_FORMAT ) + ' - '
    else
      display_dates += 'Start date dependent on next dissolution'
    end
    display_dates += self.end_on.strftime( $DATE_DISPLAY_FORMAT ) if self.end_on
    display_dates
  end
  
  def friendly_label
    friendly_label = self.start_on.strftime( '%Y' )
    if self.end_on
      friendly_label += '-' + self.end_on.strftime( '%Y' )
    end
    friendly_label += '  boundary set for '
    friendly_label += self.country_name
    friendly_label
  end
  
  def general_elections
    GeneralElection.find_by_sql([
      "
        SELECT ge.*
        FROM general_elections ge, elections e, constituency_groups cg, constituency_areas ca
        WHERE e.general_election_id = ge.id
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.boundary_set_id = ?
        AND ge.is_notional IS FALSE
        GROUP BY ge.id
        ORDER BY ge.polling_on
      ", id
    ])
  end
  
  def general_elections_with_ordinality
    GeneralElection.find_by_sql([
      "
        SELECT ge.*, geibs.ordinality
        FROM general_elections ge, general_election_in_boundary_sets geibs
        WHERE ge.id = geibs.general_election_id
        AND geibs.boundary_set_id = ?
        AND ge.is_notional IS FALSE
        AND
          /* We don't include any general elections with no results */
          /* we use valid vote count as a proxy for the general election having no results */
          ge.valid_vote_count != 0 
        ORDER BY ge.polling_on
      ", id
    ])
  end
  
  def constituency_areas
    ConstituencyArea.find_by_sql([
      "
        SELECT ca.*,
          bs.start_on AS boundary_set_start_on,
          bs.end_on AS boundary_set_end_on
        FROM constituency_areas ca, boundary_sets bs
        WHERE boundary_set_id = bs.id
        AND 
          (
            (
              bs.id = ?
            )
            OR
            (
              bs.parent_boundary_set_id = ?
            )
          )
          ORDER BY name
      ", id, id
    ])
  end
  
  def elections
    Election.find_by_sql([
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
          AND ca.boundary_set_id = ?
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
      ", id
    ])
  end
  
  def elections_in_general_elections
    Election.find_by_sql([
      "
        SELECT
          e.*,
          ( cast(e.majority as decimal) / e.valid_vote_count ) AS majority_percentage,
          winning_candidacy.vote_share AS vote_share,
          electorate.population_count AS electorate_population_count,
          constituency_area.constituency_area_name AS constituency_area_name,
          constituency_area.constituency_area_id AS constituency_area_id,
          general_election.polling_on AS general_election_polling_on,
          winning_candidacy.is_standing_as_commons_speaker AS winning_candidacy_standing_as_commons_speaker,
          winning_candidacy.is_standing_as_independent AS  winning_candidacy_standing_as_independent,
          winning_candidacy_party.party_name AS winning_candidacy_party_name,
          winning_candidacy_party.party_abbreviation AS winning_candidacy_party_abbreviation,
          winning_candidacy_party.party_id AS winning_candidacy_party_id,
          winning_candidacy_party.party_mnis_id AS main_party_mnis_id,
          winning_candidacy_adjunct_party.party_abbreviation AS winning_candidacy_adjunct_party_abbreviation,
          winning_candidacy_adjunct_party.party_name AS winning_candidacy_adjunct_party_name,
          winning_candidacy_adjunct_party.party_id AS winning_candidacy_adjunct_party_id
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM electorates
        ) AS electorate
        ON electorate.id = e.electorate_id
        
        INNER JOIN ( 
          SELECT cg.id AS constituency_group_id, ca.id AS constituency_area_id, ca.name AS constituency_area_name
          FROM constituency_groups cg, constituency_areas ca
          WHERE cg.constituency_area_id = ca.id AND ca.boundary_set_id = ?
        ) constituency_area
        ON constituency_area.constituency_group_id = e.constituency_group_id
        
        INNER JOIN (
          SELECT *
          FROM general_elections
          WHERE is_notional IS FALSE
        ) general_election
        ON general_election.id = e.general_election_id
        
        INNER JOIN (
          SELECT c.*
          FROM candidacies c
          WHERE c.is_winning_candidacy IS TRUE
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
        
        LEFT JOIN (
          SELECT can.election_id AS election_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation, pp.id AS party_id, pp.mnis_id AS party_mnis_id
          FROM candidacies can, certifications cert, political_parties pp
          WHERE can.is_winning_candidacy IS TRUE
          AND can.id = cert.candidacy_id
          AND cert.adjunct_to_certification_id IS NULL
          AND cert.political_party_id = pp.id
        ) winning_candidacy_party
        ON winning_candidacy_party.election_id = e.id
        
        LEFT JOIN (
          SELECT can.election_id AS election_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation, pp.id AS party_id
          FROM candidacies can, certifications cert, political_parties pp
          WHERE can.is_winning_candidacy IS TRUE
          AND can.id = cert.candidacy_id
          AND cert.adjunct_to_certification_id IS NOT NULL
          AND cert.political_party_id = pp.id
        ) winning_candidacy_adjunct_party
        ON winning_candidacy_adjunct_party.election_id = e.id
        
        ORDER BY constituency_area_name, general_election_polling_on
        
      ", id
    ])
  end
  
  def all_elections
    Election.find_by_sql([
      "
        SELECT
          e.*,
          ( cast(e.majority as decimal) / e.valid_vote_count ) AS majority_percentage,
          winning_candidacy.vote_share AS vote_share,
          electorate.population_count AS electorate_population_count,
          boundary_set.constituency_area_name AS constituency_area_name,
          boundary_set.constituency_area_id AS constituency_area_id,
          boundary_set.boundary_set_start_on AS boundary_set_start_on,
          boundary_set.boundary_set_end_on AS boundary_set_end_on,
          general_election.polling_on AS general_election_polling_on,
          winning_candidacy.is_standing_as_commons_speaker AS winning_candidacy_standing_as_commons_speaker,
          winning_candidacy.is_standing_as_independent AS  winning_candidacy_standing_as_independent,
          winning_candidacy_party.party_name AS winning_candidacy_party_name,
          winning_candidacy_party.party_abbreviation AS winning_candidacy_party_abbreviation,
          winning_candidacy_party.party_id AS winning_candidacy_party_id,
          winning_candidacy_party.party_mnis_id AS main_party_mnis_id,
          winning_candidacy_adjunct_party.party_name AS winning_candidacy_adjunct_party_name,
          winning_candidacy_adjunct_party.party_abbreviation AS winning_candidacy_adjunct_party_abbreviation,
          winning_candidacy_adjunct_party.party_id AS winning_candidacy_adjunct_party_id
        FROM elections e
      
        INNER JOIN (
          SELECT *
          FROM electorates
        ) AS electorate
        ON electorate.id = e.electorate_id
      
        INNER JOIN (
          SELECT
            cg.id AS constituency_group_id,
            ca.id AS constituency_area_id,
            ca.name AS constituency_area_name,
            bs.start_on AS boundary_set_start_on,
            bs.end_on AS boundary_set_end_on
          FROM constituency_groups cg, constituency_areas ca, boundary_sets bs
          WHERE cg.constituency_area_id = ca.id
          AND ca.boundary_set_id = bs.id
          AND 
            (
              (
                bs.id = ?
                AND
                bs.parent_boundary_set_id IS NULL
              )
              OR
              (
                bs.parent_boundary_set_id = ?
              )
            )
        ) AS boundary_set
        ON boundary_set.constituency_group_id = e.constituency_group_id
      
        LEFT JOIN (
          SELECT *
          FROM general_elections
          WHERE is_notional IS FALSE
        ) general_election
        ON general_election.id = e.general_election_id
      
        INNER JOIN (
          SELECT c.*
          FROM candidacies c
          WHERE c.is_winning_candidacy IS TRUE
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
      
        LEFT JOIN (
          SELECT can.election_id AS election_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation, pp.id AS party_id, pp.mnis_id AS party_mnis_id
          FROM candidacies can, certifications cert, political_parties pp
          WHERE can.is_winning_candidacy IS TRUE
          AND can.id = cert.candidacy_id
          AND cert.adjunct_to_certification_id IS NULL
          AND cert.political_party_id = pp.id
        ) winning_candidacy_party
        ON winning_candidacy_party.election_id = e.id
      
        LEFT JOIN (
          SELECT can.election_id AS election_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation, pp.id AS party_id
          FROM candidacies can, certifications cert, political_parties pp
          WHERE can.is_winning_candidacy IS TRUE
          AND can.id = cert.candidacy_id
          AND cert.adjunct_to_certification_id IS NOT NULL
          AND cert.political_party_id = pp.id
        ) winning_candidacy_adjunct_party
        ON winning_candidacy_adjunct_party.election_id = e.id
        
        WHERE e.is_notional IS FALSE
      
        ORDER BY constituency_area_name, e.polling_on
      ", id, id
    ])
  end
  
  def by_elections
    Election.find_by_sql([
      "
      SELECT e.*, cg.name AS constituency_group_name
      FROM elections e, constituency_groups cg, constituency_areas ca
      WHERE e.constituency_group_id = cg.id
      AND cg.constituency_area_id = ca.id
      AND ca.boundary_set_id = ?
      AND e.general_election_id IS NULL
      ORDER BY e.polling_on, constituency_group_name
      ", id
    ])
  end
  
  def establishing_legislation
    LegislationItem.find_by_sql([
      "
        SELECT li.*
        FROM legislation_items li, boundary_set_legislation_items bsli, boundary_sets bs
        WHERE li.id = bsli.legislation_item_id
        AND bsli.boundary_set_id = bs.id
        AND (
          bs.id = ?
          OR
          bs.parent_boundary_set_id = ?
        )
        GROUP BY li.id
        ORDER BY li.statute_book_on
      ", id, id
    ])
  end
  
  def nodes
    Node.find_by_sql([
      "
        SELECT *
        FROM nodes
        WHERE boundary_set_id = ?
      ", id
    ])
  end
  
  def edges
    Edge.find_by_sql([
      "
        SELECT e.*
        FROM edges e, nodes n
        WHERE ( e.from_node_id = n.id OR e.to_node_id = n.id )
        AND n.boundary_set_id = ?
        GROUP BY e.id
      ", id
    ])
  end
  
  def previous_boundary_set
    
    # If the boundary set we're attempting to make a previous boundary set link from is a parent boundary set ...
    if self.is_parent_boundary_set?
    
      # ... we find the preceding parent boundary set in the same country.
      BoundarySet
        .where( "start_on < ?", self.start_on )
        .where( "country_id = ?", self.country.id )
        .where( "parent_boundary_set_id IS NULL" )
        .order( "start_on desc" )
        .first
    end
  end
  
  def next_boundary_set
    
    # If the boundary set we're attempting to make a next boundary set link from is a parent boundary set ...
    if self.is_parent_boundary_set?
      BoundarySet
        .where( "start_on > ?", self.start_on )
        .where( "country_id = ?", self.country.id )
        .where( "parent_boundary_set_id IS NULL" )
        .order( "start_on" )
        .first
    end
  end
  
  def is_child_boundary_set?
    is_child_boundary_set = false
    is_child_boundary_set = true if self.parent_boundary_set_id
    is_child_boundary_set
  end
  
  def is_parent_boundary_set?
    is_parent_boundary_set = true
    is_parent_boundary_set = false if self.parent_boundary_set_id
    is_parent_boundary_set
  end
  
  def parent_boundary_set
    BoundarySet.find_by_sql([
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, countries c
        WHERE bs.country_id = c.id
        AND bs.id = ?
      ", self.parent_boundary_set_id
    ]).first
  end
end
