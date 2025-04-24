# == Schema Information
#
# Table name: political_parties
#
#  id                           :integer          not null, primary key
#  abbreviation                 :string(255)      not null
#  disclaimer                   :string(500)
#  has_been_parliamentary_party :boolean          default(FALSE)
#  name                         :string(255)      not null
#  mnis_id                      :integer
#
class PoliticalParty < ApplicationRecord
  attr_accessor :party_performances
  
  def hyphenated_name
    self.name.gsub( ' ', '-' ).downcase
  end
  
  def represented_in_election?( election )
    represented_in_election = false
    represented = Candidacy.find_by_sql([
      "
        SELECT can.*
        FROM candidacies can, certifications cert
        WHERE can.election_id = :election_id
        AND can.id = cert.candidacy_id
        AND cert.political_party_id = :political_party_id
        AND cert.adjunct_to_certification_id IS NULL
      ", election_id: election.id, political_party_id: id
    ])
    represented_in_election = true unless represented.empty?
    represented_in_election
  end
  
  def won_election?( election )
    won_election = false
    winning_candidates = Candidacy.find_by_sql([
      "
        SELECT can.*
        FROM candidacies can, certifications cert
        WHERE can.election_id = :election_id
        AND can.id = cert.candidacy_id
        AND cert.political_party_id = :political_party_id
        AND can.is_winning_candidacy IS TRUE
        AND cert.adjunct_to_certification_id IS NULL
      ", election_id: election.id, political_party_id: id
    ])
    won_election = true unless winning_candidates.empty?
    won_election
  end
  
  def winning_candidacies
    Candidacy.find_by_sql([
      "
        SELECT c.*
        FROM candidacies c, certifications cert
        WHERE c.is_winning_candidacy IS TRUE
        AND c.id = cert.candidacy_id
        AND cert.adjunct_to_certification_id IS NULL
        AND cert.political_party_id = ?
      ", id
    ])
  end
  
  def non_notional_winning_candidacies
    Candidacy.find_by_sql([
      "
        SELECT c.*
        FROM candidacies c, certifications cert
        WHERE c.is_winning_candidacy IS TRUE
        AND c.is_notional IS FALSE
        AND c.id = cert.candidacy_id
        AND cert.adjunct_to_certification_id IS NULL
        AND cert.political_party_id = ?
      ", id
    ])
  end
  
  def elections_won_in_general_election( general_election )
    Election.find_by_sql([
      "
        SELECT e.*,
          constituency_group.name AS constituency_name,
          constituency_area.geographic_code AS constituency_area_geographic_code,
          constituency_group.constituency_area_id AS constituency_area_id,
          winning_candidacy.candidate_given_name AS winning_candidacy_candidate_given_name,
          winning_candidacy.candidate_family_name AS winning_candidacy_candidate_family_name,
          winning_candidacy.vote_count AS winning_candidacy_vote_count,
          winning_candidacy.vote_share AS winning_candidacy_vote_share,
          winning_candidacy.vote_change AS winning_candidacy_vote_change,
          member.mnis_id AS member_mnis_id,
          electorate.population_count AS electorate_population_count
        FROM elections e
      
        INNER JOIN (
          SELECT can.*
          FROM candidacies can, certifications cert
  	      WHERE can.is_winning_candidacy IS TRUE
  	      AND can.id = cert.candidacy_id
          AND cert.political_party_id = :id
  	      AND cert.adjunct_to_certification_id IS NULL
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
      
        LEFT JOIN (
          SELECT m.*, can.election_id AS election_id
          FROM members m, candidacies can
          WHERE m.id = can.member_id
  	      AND can.is_winning_candidacy IS TRUE
        ) member
        ON member.election_id = e.id
        
        INNER JOIN (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        LEFT JOIN (
          SELECT *
          FROM constituency_areas
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
      
        LEFT JOIN (
          SELECT *
          FROM electorates
        ) electorate
        ON electorate.id = e.electorate_id
      
        WHERE e.general_election_id = :general_election_id
        ORDER BY constituency_name
      ", id: id, general_election_id: general_election.id
    ])
  end
  
  def elections_contested_in_general_election( general_election )
    Election.find_by_sql([
      "
        SELECT e.*,
          constituency_group.name AS constituency_name,
          constituency_area.geographic_code AS constituency_area_geographic_code,
          constituency_group.constituency_area_id AS constituency_area_id,
          candidacy.candidate_given_name AS winning_candidacy_candidate_given_name,
          candidacy.candidate_family_name AS winning_candidacy_candidate_family_name,
          candidacy.vote_count AS candidacy_vote_count,
          candidacy.vote_share AS candidacy_vote_share,
          candidacy.vote_change AS candidacy_vote_change,
          candidacy.result_position AS candidacy_result_position,
          member.mnis_id AS member_mnis_id,
          electorate.population_count AS electorate_population_count
        FROM elections e
      
        INNER JOIN (
          SELECT can.*
          FROM candidacies can, certifications cert
  	      WHERE can.id = cert.candidacy_id
          AND cert.political_party_id = :id
  	      AND cert.adjunct_to_certification_id IS NULL
        ) candidacy
        ON candidacy.election_id = e.id
        
        INNER JOIN (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        LEFT JOIN (
          SELECT *
          FROM constituency_areas
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
      
        LEFT JOIN (
          SELECT m.*, can.election_id AS election_id
          FROM members m, candidacies can, certifications cert
          WHERE m.id = can.member_id
  	      AND can.id = cert.candidacy_id
          AND cert.political_party_id = :id
  	      AND cert.adjunct_to_certification_id IS NULL
        ) member
        ON member.election_id = e.id
      
        LEFT JOIN (
          SELECT *
          FROM electorates
        ) electorate
        ON electorate.id = e.electorate_id
      
        WHERE e.general_election_id = :general_election_id
        ORDER BY constituency_name
      ", id: id, general_election_id: general_election.id
    ])
  end
  
  def elections_contested_in_general_election_in_english_region( general_election, english_region )
    Election.find_by_sql([
      "
        SELECT e.*,
          constituency_group.name AS constituency_name,
          constituency_area.geographic_code AS constituency_area_geographic_code,
          constituency_group.constituency_area_id AS constituency_area_id,
          candidacy.candidate_given_name AS winning_candidacy_candidate_given_name,
          candidacy.candidate_family_name AS winning_candidacy_candidate_family_name,
          candidacy.vote_count AS candidacy_vote_count,
          candidacy.vote_share AS candidacy_vote_share,
          candidacy.vote_change AS candidacy_vote_change,
          candidacy.result_position AS candidacy_result_position,
          member.mnis_id AS member_mnis_id,
          electorate.population_count AS electorate_population_count
        FROM elections e
      
        INNER JOIN (
          SELECT can.*
          FROM candidacies can, certifications cert
  	      WHERE can.id = cert.candidacy_id
          AND cert.political_party_id = :political_party_id
  	      AND cert.adjunct_to_certification_id IS NULL
        ) candidacy
        ON candidacy.election_id = e.id
        
        INNER JOIN (
          SELECT cg.*
          FROM constituency_groups cg, constituency_areas ca
          WHERE cg.constituency_area_id = ca.id
          AND ca.english_region_id = :english_region_id
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        LEFT JOIN (
          SELECT *
          FROM constituency_areas
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
      
        LEFT JOIN (
          SELECT m.*, can.election_id AS election_id
          FROM members m, candidacies can, certifications cert
          WHERE m.id = can.member_id
  	      AND can.id = cert.candidacy_id
          AND cert.political_party_id = :political_party_id
  	      AND cert.adjunct_to_certification_id IS NULL
        ) member
        ON member.election_id = e.id
      
        LEFT JOIN (
          SELECT *
          FROM electorates
        ) electorate
        ON electorate.id = e.electorate_id
      
        WHERE e.general_election_id = :general_election_id
        ORDER BY constituency_name
      ", political_party_id: id, general_election_id: general_election.id, english_region_id: english_region.id
    ])
  end
  
  def elections_won_in_general_election_in_english_region( general_election, english_region )
    Election.find_by_sql([
      "
        SELECT e.*,
          constituency_group.name AS constituency_name,
          constituency_area.geographic_code AS constituency_area_geographic_code,
          constituency_group.constituency_area_id AS constituency_area_id,
          winning_candidacy.candidate_given_name AS winning_candidacy_candidate_given_name,
          winning_candidacy.candidate_family_name AS winning_candidacy_candidate_family_name,
          winning_candidacy.vote_count AS winning_candidacy_vote_count,
          winning_candidacy.vote_share AS winning_candidacy_vote_share,
          winning_candidacy.vote_change AS winning_candidacy_vote_change,
          member.mnis_id AS member_mnis_id,
          electorate.population_count AS electorate_population_count
        FROM elections e
      
        INNER JOIN (
          SELECT can.*
          FROM candidacies can, certifications cert
  	      WHERE can.is_winning_candidacy IS TRUE
  	      AND can.id = cert.candidacy_id
          AND cert.political_party_id = :political_party_id
  	      AND cert.adjunct_to_certification_id IS NULL
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
      
        LEFT JOIN (
          SELECT m.*, can.election_id AS election_id
          FROM members m, candidacies can
          WHERE m.id = can.member_id
  	      AND can.is_winning_candidacy IS TRUE
        ) member
        ON member.election_id = e.id
        
        INNER JOIN (
          SELECT cg.*
          FROM constituency_groups cg, constituency_areas ca
          WHERE cg.constituency_area_id = ca.id
          AND ca.english_region_id = :english_region_id
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        LEFT JOIN (
          SELECT *
          FROM constituency_areas
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
      
        LEFT JOIN (
          SELECT *
          FROM electorates
        ) electorate
        ON electorate.id = e.electorate_id
      
        WHERE e.general_election_id = :general_election_id
        ORDER BY constituency_name
      ", political_party_id: id, general_election_id: general_election.id, english_region_id: english_region.id
    ])
  end
  
  def elections_contested_in_general_election_in_country( general_election, country )
    Election.find_by_sql([
      "
        SELECT e.*,
          constituency_group.name AS constituency_name,
          constituency_group.constituency_area_id AS constituency_area_id,
          constituency_area.geographic_code AS constituency_area_geographic_code,
          candidacy.candidate_given_name AS winning_candidacy_candidate_given_name,
          candidacy.candidate_family_name AS winning_candidacy_candidate_family_name,
          candidacy.vote_count AS candidacy_vote_count,
          candidacy.vote_share AS candidacy_vote_share,
          candidacy.vote_change AS candidacy_vote_change,
          candidacy.result_position AS candidacy_result_position,
          member.mnis_id AS member_mnis_id,
          electorate.population_count AS electorate_population_count
        FROM elections e
      
        INNER JOIN (
          SELECT can.*
          FROM candidacies can, certifications cert
  	      WHERE can.id = cert.candidacy_id
          AND cert.political_party_id = :political_party_id
  	      AND cert.adjunct_to_certification_id IS NULL
        ) candidacy
        ON candidacy.election_id = e.id
        
        INNER JOIN (
          SELECT cg.*
          FROM constituency_groups cg, constituency_areas ca, countries c
          WHERE cg.constituency_area_id = ca.id
          AND ca.country_id = c.id
          AND(
            c.id = :country_id
            OR
            c.parent_country_id = :country_id
          )
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        LEFT JOIN (
          SELECT *
          FROM constituency_areas
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
      
        LEFT JOIN (
          SELECT m.*, can.election_id AS election_id
          FROM members m, candidacies can, certifications cert
          WHERE m.id = can.member_id
  	      AND can.id = cert.candidacy_id
          AND cert.political_party_id = :political_party_id
  	      AND cert.adjunct_to_certification_id IS NULL
        ) member
        ON member.election_id = e.id
      
        LEFT JOIN (
          SELECT *
          FROM electorates
        ) electorate
        ON electorate.id = e.electorate_id
      
        WHERE e.general_election_id = :general_election_id
        ORDER BY constituency_name
      ", political_party_id: id, general_election_id: general_election.id, country_id: country.id
    ])
  end
  
  def elections_won_in_general_election_in_country( general_election, country )
    Election.find_by_sql([
      "
        SELECT e.*,
          constituency_group.name AS constituency_name,
          constituency_group.constituency_area_id AS constituency_area_id,
          constituency_area.geographic_code AS constituency_area_geographic_code,
          winning_candidacy.candidate_given_name AS winning_candidacy_candidate_given_name,
          winning_candidacy.candidate_family_name AS winning_candidacy_candidate_family_name,
          winning_candidacy.vote_count AS winning_candidacy_vote_count,
          winning_candidacy.vote_share AS winning_candidacy_vote_share,
          winning_candidacy.vote_change AS winning_candidacy_vote_change,
          member.mnis_id AS member_mnis_id,
          electorate.population_count AS electorate_population_count
        FROM elections e
      
        INNER JOIN (
          SELECT can.*
          FROM candidacies can, certifications cert
  	      WHERE can.is_winning_candidacy IS TRUE
  	      AND can.id = cert.candidacy_id
          AND cert.political_party_id = :political_party_id
  	      AND cert.adjunct_to_certification_id IS NULL
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
      
        LEFT JOIN (
          SELECT m.*, can.election_id AS election_id
          FROM members m, candidacies can
          WHERE m.id = can.member_id
  	      AND can.is_winning_candidacy IS TRUE
        ) member
        ON member.election_id = e.id
        
        INNER JOIN (
          SELECT cg.*
          FROM constituency_groups cg, constituency_areas ca, countries c
          WHERE cg.constituency_area_id = ca.id
          AND ca.country_id = c.id
          AND (
            c.id = :country_id
            OR
            c.parent_country_id = :country_id
          )
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        LEFT JOIN (
          SELECT *
          FROM constituency_areas
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
      
        LEFT JOIN (
          SELECT *
          FROM electorates
        ) electorate
        ON electorate.id = e.electorate_id
      
        WHERE e.general_election_id = :general_election_id
        ORDER BY constituency_name
      ", political_party_id: id, general_election_id: general_election.id, country_id: country.id
    ])
  end
  
  def general_elections
    GeneralElectionPartyPerformance.find_by_sql([
      "
        SELECT gepp.*, ge.polling_on AS general_election_polling_on
        FROM general_election_party_performances gepp, general_elections ge
        WHERE gepp.political_party_id = ?
        AND gepp.general_election_id = ge.id
        AND ge.is_notional IS FALSE
        ORDER BY general_election_polling_on DESC
      ", id
    ])
  end
  
  def registrations
    PoliticalPartyRegistration.find_by_sql([
        "
          SELECT ppr.*,
            pp.name AS party_name,
            pp.abbreviation AS party_abbreviation,
            pp.mnis_id AS party_mnis_id,
            pp.id AS party_id,
            c.name AS country_name,
            c.geographic_code AS country_geographic_code
          FROM political_party_registrations ppr, political_parties pp, countries c
          WHERE ppr.political_party_id = pp.id
          AND pp.id = ?
          AND ppr.country_id = c.id
          ORDER BY pp.name, c.name, ppr.start_on
        ", id
      ])
  end
  
  def political_parties_sharing_registrations
    PoliticalParty.find_by_sql([
      "
        SELECT pp.*
        FROM political_parties pp, political_party_registrations ppr_from_party, political_party_registrations ppr_to_party
        WHERE pp.id = ppr_to_party.political_party_id
        AND ppr_to_party.electoral_commission_id = ppr_from_party.electoral_commission_id
        AND ppr_from_party.political_party_id = ?
        AND pp.id != ?
        ORDER BY pp.name
      ", id, id
    ])
  end
  
  def by_election_candidacies
    Candidacy.find_by_sql([
      "
        SELECT c.*,
          election.polling_on AS election_polling_on,
          constituency_group.name AS constituency_group_name,
          constituency_area_id AS constituency_area_id,
          member.mnis_id AS member_mnis_id
          
        FROM candidacies c
        
        LEFT JOIN (
          SELECT *
          FROM members
        ) member
        ON member.id = c.member_id
        
        INNER JOIN (
          SELECT *
          FROM certifications
          WHERE political_party_id = ?
          AND adjunct_to_certification_id IS NULL
        ) certification
        ON certification.candidacy_id = c.id
        
        INNER JOIN (
          SELECT *
          FROM elections
          WHERE general_election_id IS NULL
          AND is_notional IS FALSE
        ) election
        ON election.id = c.election_id
        
        INNER JOIN (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = election.constituency_group_id
        
        LEFT JOIN (
          SELECT *
          FROM constituency_areas
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
        
        ORDER BY election_polling_on DESC
      ", id
    ])
  end
  
  def by_election_candidacies_in_parliament_period( parliament_period )
    Candidacy.find_by_sql([
      "
        SELECT c.*,
          election.polling_on AS election_polling_on,
          constituency_group.name AS constituency_group_name,
          constituency_area_id AS constituency_area_id,
          member.mnis_id AS member_mnis_id
          
        FROM candidacies c
        
        LEFT JOIN (
          SELECT *
          FROM members
        ) member
        ON member.id = c.member_id
        
        INNER JOIN (
          SELECT *
          FROM certifications
          WHERE political_party_id = :political_party_id
          AND adjunct_to_certification_id IS NULL
        ) certification
        ON certification.candidacy_id = c.id
        
        INNER JOIN (
          SELECT *
          FROM elections
          WHERE general_election_id IS NULL
          AND is_notional IS FALSE
          AND parliament_period_id = :parliament_period_id
        ) election
        ON election.id = c.election_id
        
        INNER JOIN (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = election.constituency_group_id
        
        LEFT JOIN (
          SELECT *
          FROM constituency_areas
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
        
        ORDER BY election_polling_on DESC
      ", political_party_id: id, parliament_period_id: parliament_period.id
    ])
  end
  
  def parliament_periods_having_by_elections
    ParliamentPeriod.find_by_sql([
      "
        SELECT pp.*
        FROM parliament_periods pp, elections e, candidacies cand, certifications cert
        WHERE pp.id = e.parliament_period_id
        AND e.is_notional IS FALSE
        AND e.general_election_id IS NULL
        AND e.id = cand.election_id
        AND cand.id = cert.candidacy_id
        AND cert.adjunct_to_certification_id IS NULL
        AND cert.political_party_id = ?
        GROUP BY pp.id
        ORDER BY pp.number DESC
        
      ", id
    ])
  end
  
  def maiden_speeches
    MaidenSpeech.find_by_sql([
      "
        SELECT ms.*,
          member.given_name AS member_given_name,
          member.family_name AS member_family_name,
          member.mnis_id AS member_mnis_id,
          constituency_group.name AS constituency_group_name,
          constituency_area_id AS constituency_area_id,
          main_political_party.id AS main_political_party_id,
          main_political_party.name AS main_political_party_name,
          adjunct_political_party.id AS adjunct_political_party_id,
          adjunct_political_party.name AS adjunct_political_party_name,
          parliament_period.number AS parliament_period_number
        
        FROM maiden_speeches ms
        
        INNER JOIN (
          SELECT *
          FROM members
        ) member
        ON member.id = ms.member_id
      
        LEFT JOIN (
          SELECT *
          FROM political_parties
        ) main_political_party
        ON main_political_party.id = ms.main_political_party_id
      
        LEFT JOIN (
          SELECT *
          FROM political_parties
        ) adjunct_political_party
        ON adjunct_political_party.id = ms.adjunct_political_party_id
      
        INNER join (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = ms.constituency_group_id
      
        LEFT JOIN (
          SELECT *
          FROM constituency_areas
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
        
        INNER JOIN (
          SELECT *
          FROM parliament_periods
        ) parliament_period
        ON parliament_period.id = ms.parliament_period_id
      
        WHERE ms.main_political_party_id = ?
        ORDER BY ms.made_on
      ", id
    ])
  end
end
