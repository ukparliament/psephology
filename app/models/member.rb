# == Schema Information
#
# Table name: members
#
#  id          :integer          not null, primary key
#  family_name :string(255)      not null
#  given_name  :string(255)      not null
#  mnis_id     :integer          not null
#
class Member < ApplicationRecord
  
  def display_name
    self.given_name + ' ' + self.family_name
  end
  
  def list_name
    self.family_name + ', ' + self.given_name
  end
  
  def elections
    Election.find_by_sql([
      "
        SELECT
          e.*,
          constituency_group.name AS constituency_name,
          constituency_area.id AS constituency_area_id,
          electorate.population_count AS electorate_population_count,
          candidacy.result_position AS candidacy_result_position,
          candidacy.is_winning_candidacy AS candidacy_is_winning_candidacy,
          candidacy.vote_count AS candidacy_vote_count,
          candidacy.vote_share AS candidacy_vote_share,
          candidacy.is_standing_as_commons_speaker AS candidacy_standing_as_commons_speaker,
          candidacy.is_standing_as_independent AS candidacy_standing_as_independent,
          general_election.polling_on AS general_election_polling_on,
          main_party.id AS main_party_id,
          main_party.name AS main_party_name,
          main_party.abbreviation AS main_party_abbreviation,
          main_party.mnis_id AS main_party_mnis_id,
          adjunct_party.name AS adjunct_party_name,
          adjunct_party.id AS adjunct_party_id,
          adjunct_party.abbreviation AS adjunct_party_abbreviation
        
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM candidacies
          WHERE member_id = ?
        ) candidacy
        ON candidacy.election_id = e.id
        
        LEFT JOIN (
          SELECT cert.candidacy_id, pp.*
          FROM political_parties pp, certifications cert
          WHERE cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NULL
        ) main_party
        ON main_party.candidacy_id = candidacy.id
        
        LEFT JOIN (
          SELECT cert.candidacy_id, pp.*
          FROM political_parties pp, certifications cert
          WHERE cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NOT NULL
        ) adjunct_party
        ON adjunct_party.candidacy_id = candidacy.id
        
        INNER JOIN (
          SELECT * 
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        INNER JOIN (
          SELECT * 
          FROM electorates
        ) electorate
        ON electorate.id = e.electorate_id
        
        LEFT JOIN (
          SELECT ca.*, cg.id AS constituency_group_id
          FROM constituency_groups cg, constituency_areas ca
          WHERE cg.constituency_area_id = ca.id
        ) constituency_area
        ON constituency_area.constituency_group_id = e.constituency_group_id
        
        LEFT JOIN (
          SELECT *
          FROM general_elections
        ) general_election
        ON general_election.id = e.general_election_id
        
        ORDER BY e.polling_on DESC
      ", id
    ])
  end
  
  def elections_won
    Election.find_by_sql([
      "
        SELECT
          e.*,
          constituency_group.name AS constituency_name,
          constituency_area.id AS constituency_area_id,
          electorate.population_count AS electorate_population_count,
          candidacy.result_position AS candidacy_result_position,
          candidacy.is_winning_candidacy AS candidacy_is_winning_candidacy,
          candidacy.vote_count AS candidacy_vote_count,
          candidacy.vote_share AS candidacy_vote_share,
          candidacy.is_standing_as_commons_speaker AS candidacy_standing_as_commons_speaker,
          candidacy.is_standing_as_independent AS candidacy_standing_as_independent,
          general_election.polling_on AS general_election_polling_on,
          main_party.id AS main_party_id,
          main_party.name AS main_party_name,
          main_party.abbreviation AS main_party_abbreviation,
          main_party.mnis_id AS main_party_mnis_id,
          adjunct_party.name AS adjunct_party_name,
          adjunct_party.id AS adjunct_party_id,
          adjunct_party.abbreviation AS adjunct_party_abbreviation
        
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM candidacies
          WHERE member_id = ?
          AND is_winning_candidacy IS TRUE
        ) candidacy
        ON candidacy.election_id = e.id
        
        LEFT JOIN (
          SELECT cert.candidacy_id, pp.*
          FROM political_parties pp, certifications cert
          WHERE cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NULL
        ) main_party
        ON main_party.candidacy_id = candidacy.id
        
        LEFT JOIN (
          SELECT cert.candidacy_id, pp.*
          FROM political_parties pp, certifications cert
          WHERE cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NOT NULL
        ) adjunct_party
        ON adjunct_party.candidacy_id = candidacy.id
        
        INNER JOIN (
          SELECT * 
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        INNER JOIN (
          SELECT * 
          FROM electorates
        ) electorate
        ON electorate.id = e.electorate_id
        
        LEFT JOIN (
          SELECT ca.*, cg.id AS constituency_group_id
          FROM constituency_groups cg, constituency_areas ca
          WHERE cg.constituency_area_id = ca.id
        ) constituency_area
        ON constituency_area.constituency_group_id = e.constituency_group_id
        
        LEFT JOIN (
          SELECT *
          FROM general_elections
        ) general_election
        ON general_election.id = e.general_election_id
        
        ORDER BY e.polling_on DESC
      ", id
    ])
  end
  
  def maiden_speech
    MaidenSpeech.find_by_sql([
      "
        SELECT ms.*,
          constituency_group.name AS constituency_group_name,
          constituency_area_id AS constituency_area_id,
          parliament_period.number AS parliament_period_number
          
        FROM maiden_speeches ms
        
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
        
        
        WHERE ms.member_id = ?
      ", id
    ]).first
  end
end
