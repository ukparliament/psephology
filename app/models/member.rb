class Member < ApplicationRecord
  
  def display_name
    self.given_name + ' ' + self.family_name
  end
  
  def list_name
    self.family_name + ', ' + self.given_name
  end
  
  def elections_won
    Election.find_by_sql(
      "
        SELECT
          e.*,
          constituency.name AS constituency_name
        
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM candidacies
          WHERE member_id = #{self.id}
          AND is_winning_candidacy IS TRUE
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
        
        INNER JOIN (
          SELECT * 
          FROM constituency_groups
        ) constituency
        ON constituency.id = e.constituency_group_id
        
        ORDER BY e.polling_on DESC
      "
    )
  end
  
  def other_elections_contested
    Election.find_by_sql(
      "
        SELECT
          e.*,
          constituency.name AS constituency_name
        
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM candidacies
          WHERE member_id = #{self.id}
          AND is_winning_candidacy IS FALSE
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
        
        INNER JOIN (
          SELECT * 
          FROM constituency_groups
        ) constituency
        ON constituency.id = e.constituency_group_id
        
        ORDER BY e.polling_on DESC
      "
    )
  end
end
