class GeneralElectionCandidacyController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    
    @candidacies_simple = Candidacy.find_by_sql(
      "
        SELECT cand.*
        FROM candidacies cand, elections e
        WHERE cand.election_id = e.id
        AND e.general_election_id = #{@general_election.id}
      "
    )
    
    @candidacies = @general_election.candidacies
  end
end
