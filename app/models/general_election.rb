class GeneralElection < ApplicationRecord
  
  belongs_to :parliament_period
  attr_accessor :constituencies_won
  
  def elections
    Election.find_by_sql(
      "
        SELECT e.*, cg.name AS constituency_group_name, elec.population_count AS electorate_population_count
        FROM elections e, constituency_groups cg, electorates elec
        WHERE e.general_election_id = #{self.id}
        AND e.constituency_group_id = cg.id
        AND e.electorate_id = elec.id
        ORDER BY constituency_group_name
      "
    )
  end
  
  def elections_in_country( country )
    Election.find_by_sql(
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg, constituency_areas ca
        WHERE e.general_election_id = #{self.id}
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.country_id = #{country.id}
        ORDER BY cg.name
      "
    )
  end
  
  def elections_in_english_region( english_region )
    Election.find_by_sql(
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg, constituency_areas ca
        WHERE e.general_election_id = #{self.id}
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.english_region_id = #{english_region.id}
        ORDER BY cg.name
      "
    )
  end
  
  def elections_by_majority
    Election.find_by_sql(
      "
        SELECT e.*,
          constituency_group.name AS constituency_group_name,
          ( cast(e.majority as decimal) / e.valid_vote_count ) AS majority_percentage,
          winning_candidacy.candidate_given_name AS winning_candidacy_candidate_given_name,
          winning_candidacy.candidate_family_name AS winning_candidacy_candidate_family_name,
          winning_candidacy.is_standing_as_commons_speaker AS  winning_candidacy_standing_as_commons_speaker,
          winning_candidacy.is_standing_as_independent AS  winning_candidacy_standing_as_independent,
          winning_candidacy_party.party_id AS main_party_id,
          winning_candidacy_party.party_name AS main_party_name,
          winning_candidacy_party.party_abbreviation AS main_party_abbreviation,
          winning_candidacy_adjunct_party.party_id AS adjunct_party_id,
          winning_candidacy_adjunct_party.party_name AS adjunct_party_name,
          winning_candidacy_adjunct_party.party_abbreviation AS adjunct_party_abbreviation,
          winning_candidacy_member.mnis_id AS winning_candidacy_mnis_id
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        INNER JOIN (
          SELECT c.*
          FROM candidacies c
          WHERE c.is_winning_candidacy IS TRUE
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
        
        INNER JOIN (
          SELECT c.*, m.mnis_id
          FROM candidacies c, members m
          WHERE c.is_winning_candidacy IS TRUE
          AND c.member_id = m.id
        ) winning_candidacy_member
        ON winning_candidacy_member.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, pp.id AS party_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation
          FROM candidacies c, certifications cert, political_parties pp
          WHERE cert.candidacy_id = c.id
          AND cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NULL
          AND c.is_winning_candidacy IS TRUE
        ) winning_candidacy_party
        ON winning_candidacy_party.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, pp.id AS party_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation
          FROM candidacies c, certifications cert, political_parties pp
          WHERE cert.candidacy_id = c.id
          AND cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NOT NULL
          AND c.is_winning_candidacy IS TRUE
        ) winning_candidacy_adjunct_party
        ON winning_candidacy_adjunct_party.election_id = e.id
      
        
        WHERE general_election_id = #{self.id}
        ORDER BY majority_percentage DESC
      "
    )
  end
  
  def elections_by_turnout
    Election.find_by_sql(
      "
        SELECT e.*,
          constituency_group.name AS constituency_group_name,
          ( cast(e.majority as decimal) / e.valid_vote_count ) AS majority_percentage,
          winning_candidacy.candidate_given_name AS winning_candidacy_candidate_given_name,
          winning_candidacy.candidate_family_name AS winning_candidacy_candidate_family_name,
          winning_candidacy.is_standing_as_commons_speaker AS  winning_candidacy_standing_as_commons_speaker,
          winning_candidacy.is_standing_as_independent AS  winning_candidacy_standing_as_independent,
          winning_candidacy_party.party_id AS main_party_id,
          winning_candidacy_party.party_name AS main_party_name,
          winning_candidacy_party.party_abbreviation AS main_party_abbreviation,
          winning_candidacy_adjunct_party.party_id AS adjunct_party_id,
          winning_candidacy_adjunct_party.party_name AS adjunct_party_name,
          winning_candidacy_adjunct_party.party_abbreviation AS adjunct_party_abbreviation,
          electorate.population_count AS electorate_population_count,
          ( cast(e.valid_vote_count as decimal) / electorate.population_count ) AS turnout_percentage,
          winning_candidacy_member.mnis_id AS winning_candidacy_mnis_id
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM electorates
        ) electorate
        ON electorate.id = e.electorate_id
        
        INNER JOIN (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        INNER JOIN (
          SELECT c.*
          FROM candidacies c
          WHERE c.is_winning_candidacy IS TRUE
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
        
        INNER JOIN (
          SELECT c.*, m.mnis_id
          FROM candidacies c, members m
          WHERE c.is_winning_candidacy IS TRUE
          AND c.member_id = m.id
        ) winning_candidacy_member
        ON winning_candidacy_member.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, pp.id AS party_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation
          FROM candidacies c, certifications cert, political_parties pp
          WHERE cert.candidacy_id = c.id
          AND cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NULL
          AND c.is_winning_candidacy IS TRUE
        ) winning_candidacy_party
        ON winning_candidacy_party.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, pp.id AS party_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation
          FROM candidacies c, certifications cert, political_parties pp
          WHERE cert.candidacy_id = c.id
          AND cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NOT NULL
          AND c.is_winning_candidacy IS TRUE
        ) winning_candidacy_adjunct_party
        ON winning_candidacy_adjunct_party.election_id = e.id
      
        
        WHERE general_election_id = #{self.id}
        ORDER BY turnout_percentage DESC
      "
    )
  end
  
  def elections_by_vote_share
    Election.find_by_sql(
      "
        SELECT e.*,
          constituency_group.name AS constituency_group_name,
          ( cast(e.majority as decimal) / e.valid_vote_count ) AS majority_percentage,
          winning_candidacy.candidate_given_name AS winning_candidacy_candidate_given_name,
          winning_candidacy.candidate_family_name AS winning_candidacy_candidate_family_name,
          winning_candidacy.is_standing_as_commons_speaker AS  winning_candidacy_standing_as_commons_speaker,
          winning_candidacy.is_standing_as_independent AS  winning_candidacy_standing_as_independent,
          winning_candidacy_party.party_id AS main_party_id,
          winning_candidacy_party.party_name AS main_party_name,
          winning_candidacy_party.party_abbreviation AS main_party_abbreviation,
          winning_candidacy_adjunct_party.party_id AS adjunct_party_id,
          winning_candidacy_adjunct_party.party_name AS adjunct_party_name,
          winning_candidacy_adjunct_party.party_abbreviation AS adjunct_party_abbreviation,
          winning_candidacy.vote_share AS vote_share,
          winning_candidacy_member.mnis_id AS winning_candidacy_mnis_id
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        INNER JOIN (
          SELECT c.*
          FROM candidacies c
          WHERE c.is_winning_candidacy IS TRUE
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
        
        INNER JOIN (
          SELECT c.*, m.mnis_id
          FROM candidacies c, members m
          WHERE c.is_winning_candidacy IS TRUE
          AND c.member_id = m.id
        ) winning_candidacy_member
        ON winning_candidacy_member.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, pp.id AS party_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation
          FROM candidacies c, certifications cert, political_parties pp
          WHERE cert.candidacy_id = c.id
          AND cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NULL
          AND c.is_winning_candidacy IS TRUE
        ) winning_candidacy_party
        ON winning_candidacy_party.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, pp.id AS party_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation
          FROM candidacies c, certifications cert, political_parties pp
          WHERE cert.candidacy_id = c.id
          AND cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NOT NULL
          AND c.is_winning_candidacy IS TRUE
        ) winning_candidacy_adjunct_party
        ON winning_candidacy_adjunct_party.election_id = e.id
      
        
        WHERE general_election_id = #{self.id}
        ORDER BY vote_share DESC
      "
    )
  end
  
  def party_performance
    GeneralElectionPartyPerformance.find_by_sql(
      "
        SELECT gepp.*, pp.name AS party_name, ge.valid_vote_count AS general_election_valid_vote_count
        FROM general_election_party_performances gepp, political_parties pp, general_elections ge
        WHERE gepp.general_election_id = #{self.id}
        AND gepp.political_party_id = pp.id
        AND gepp.constituency_contested_count > 0
        AND gepp.general_election_id = ge.id
        ORDER BY gepp.constituency_won_count DESC, cumulative_vote_count DESC, constituency_contested_count DESC
      "
    )
  end
  
  def preceding_general_election
    GeneralElection.find_by_sql(
      "
        SELECT ge.*
        FROM general_elections ge
        WHERE polling_on < '#{self.polling_on}'
        ORDER BY polling_on DESC
      "
    ).first
  end
  
  def countries
    Country.find_by_sql(
      "
        SELECT c.*
        FROM countries c, constituency_areas ca, constituency_groups cg, elections e
        WHERE c.id = ca.country_id
        AND cg.constituency_area_id = ca.id
        AND e.constituency_group_id = cg.id
        AND e.general_election_id = #{self.id}
        GROUP BY c.id
        ORDER by c.name
      "
    )
  end
  
  def english_regions_in_country( country )
    EnglishRegion.find_by_sql(
      "
        SELECT er.*
        FROM english_regions er, constituency_areas ca, constituency_groups cg, elections e
        WHERE er.id = ca.english_region_id
        AND er.country_id = #{country.id}
        AND cg.constituency_area_id = ca.id
        AND e.constituency_group_id = cg.id
        AND e.general_election_id = #{self.id}
        GROUP BY er.id
        ORDER by er.name
      "
    )
  end
  
  def elections_in_boundary_set( boundary_set )
    Election.find_by_sql(
      "
        SELECT e.*
        FROM elections e, constituency_groups cg, constituency_areas ca
        WHERE e.general_election_id = #{self.id}
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.boundary_set_id = #{boundary_set.id}
      "
    )
  end
  
  def previous_general_election
    GeneralElection.where( "polling_on < ?", self.polling_on ).order( "polling_on desc" ).first
  end
  
  def next_general_election
    GeneralElection.where( "polling_on > ?", self.polling_on ).order( "polling_on" ).first
  end
  
  def uncertified_candidacies
    Candidacy.find_by_sql(
      "
        SELECT c.*,
          election.constituency_group_name AS constituency_group_name,
          member.mnis_id AS candidate_mnis_id,
          CASE
            WHEN is_standing_as_independent IS TRUE THEN 'Independent'
            WHEN is_standing_as_commons_speaker IS TRUE THEN 'Commons Speaker'
          END AS standing_as
        FROM candidacies c
        
        INNER JOIN (
          SELECT e.*, cg.name AS constituency_group_name
          FROM elections e, constituency_groups cg
          WHERE e.constituency_group_id = cg.id
          AND e.general_election_id = #{self.id}
        ) election
        ON election.id = c.election_id
        
        LEFT JOIN (
          SELECT *
          FROM members
        ) member
        ON member.id = c.member_id
        
        WHERE ( c.is_standing_as_independent IS TRUE OR is_standing_as_commons_speaker IS TRUE )
        ORDER BY standing_as, constituency_group_name
        
        
      "
    )
  end
end
