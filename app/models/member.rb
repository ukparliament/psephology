class Member < ApplicationRecord
  
  def display_name
    self.given_name + ' ' + self.family_name
  end
  
  def list_name
    self.family_name + ', ' + self.given_name
  end
  
  def elections
    Election.find_by_sql(
      "
        SELECT
          e.*,
          constituency_group.name AS constituency_name,
          constituency_area.id AS constituency_area_id,
          candidacy.result_position AS candidacy_result_position,
          candidacy.is_winning_candidacy AS candidacy_is_winning_candidacy,
          candidacy.vote_count AS candidacy_vote_count,
          candidacy.vote_share AS candidacy_vote_share,
          general_election.polling_on AS general_election_polling_on
        
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM candidacies
          WHERE member_id = #{self.id}
        ) candidacy
        ON candidacy.election_id = e.id
        
        INNER JOIN (
          SELECT * 
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
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
      "
    )
  end
  
  def elections_won
    Election.find_by_sql(
      "
        SELECT
          e.*,
          constituency_group.name AS constituency_name,
          constituency_area.id AS constituency_area_id,
          candidacy.result_position AS candidacy_result_position,
          candidacy.is_winning_candidacy AS candidacy_is_winning_candidacy,
          candidacy.vote_count AS candidacy_vote_count,
          candidacy.vote_share AS candidacy_vote_share,
          general_election.polling_on AS general_election_polling_on
        
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM candidacies
          WHERE member_id = #{self.id}
          AND is_winning_candidacy IS TRUE
        ) candidacy
        ON candidacy.election_id = e.id
        
        INNER JOIN (
          SELECT * 
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
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
      "
    )
  end
end
