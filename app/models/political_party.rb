class PoliticalParty < ApplicationRecord
  
  def represented_in_election?( election )
    represented_in_election = false
    represented = Candidacy.find_by_sql( 
      "
        SELECT can.*
        FROM candidacies can, certifications cert
        WHERE can.election_id = #{election.id}
        AND can.id = cert.candidacy_id
        AND cert.political_party_id = #{self.id}
        AND cert.adjunct_to_certification_id IS NULL
      "
    )
    represented_in_election = true unless represented.empty?
    represented_in_election
  end
  
  def won_election?( election )
    won_election = false
    winning_candidates = Candidacy.find_by_sql( 
      "
        SELECT can.*
        FROM candidacies can, certifications cert
        WHERE can.election_id = #{election.id}
        AND can.id = cert.candidacy_id
        AND cert.political_party_id = #{self.id}
        AND can.is_winning_candidacy IS TRUE
        AND cert.adjunct_to_certification_id IS NULL
      "
    )
    won_election = true unless winning_candidates.empty?
    won_election
  end
  
  def winning_candidacies
    Candidacy.find_by_sql(
      "
        SELECT c.*
        FROM candidacies c, certifications cert
        WHERE c.is_winning_candidacy IS TRUE
        AND c.id = cert.candidacy_id
        AND cert.adjunct_to_certification_id IS NULL
        AND cert.political_party_id = #{self.id}
      "
    )
  end
  
  def non_notional_winning_candidacies
    Candidacy.find_by_sql(
      "
        SELECT c.*
        FROM candidacies c, certifications cert
        WHERE c.is_winning_candidacy IS TRUE
        AND c.is_notional IS FALSE
        AND c.id = cert.candidacy_id
        AND cert.adjunct_to_certification_id IS NULL
        AND cert.political_party_id = #{self.id}
      "
    )
  end
  
  def elections_won_in_general_election( general_election )
    Election.find_by_sql(
      "
        SELECT e.*,
          constituency_group.name AS constituency_name,
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
          AND cert.political_party_id = #{self.id}
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
          FROM electorates
        ) electorate
        ON electorate.id = e.electorate_id
      
        WHERE e.general_election_id = #{general_election.id}
        ORDER BY constituency_name
      "
    )
  end
  
  def elections_contested_in_general_election( general_election )
    Election.find_by_sql(
      "
        SELECT e.*,
          constituency_group.name AS constituency_name,
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
          AND cert.political_party_id = #{self.id}
  	      AND cert.adjunct_to_certification_id IS NULL
        ) candidacy
        ON candidacy.election_id = e.id
        
        INNER JOIN (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
      
        LEFT JOIN (
          SELECT m.*, can.election_id AS election_id
          FROM members m, candidacies can, certifications cert
          WHERE m.id = can.member_id
  	      AND can.id = cert.candidacy_id
          AND cert.political_party_id = #{self.id}
  	      AND cert.adjunct_to_certification_id IS NULL
        ) member
        ON member.election_id = e.id
      
        LEFT JOIN (
          SELECT *
          FROM electorates
        ) electorate
        ON electorate.id = e.electorate_id
      
        WHERE e.general_election_id = #{general_election.id}
        ORDER BY constituency_name
      "
    )
  end
  
  def general_elections
    GeneralElectionPartyPerformance.find_by_sql(
      "
        SELECT gepp.*, ge.polling_on AS general_election_polling_on
        FROM general_election_party_performances gepp, general_elections ge
        WHERE gepp.political_party_id = #{self.id}
        AND gepp.general_election_id = ge.id
        ORDER BY general_election_polling_on DESC
      "
    )
  end
end
