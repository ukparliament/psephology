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
end
