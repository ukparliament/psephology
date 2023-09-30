class ByElectionController < ApplicationController
  
  def index
    @by_elections = Election.find_by_sql(
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg
        WHERE e.constituency_group_id = cg.id
        AND general_election_id IS NULL
        ORDER BY polling_on DESC, constituency_group_name
      "
    )
    @page_title = 'By-elections'
  end
end
