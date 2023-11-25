class BoundarySetGeneralElectionPartyController < ApplicationController
  
  def index
    boundary_set = params[:boundary_set]
    
    @boundary_set = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, countries c
        WHERE bs.country_id = c.id
        AND bs.id = #{boundary_set}
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @boundary_set
    
    # We get all the general elections held during the duration of the boundary set.
    @general_elections = @boundary_set.general_elections
    
    # We get the parties.
    @parties = BoundarySetGeneralElectionPartyPerformance.find_by_sql(
      "
        SELECT
          bsgepp.*,
          pp.name AS political_party_name,
          ge.polling_on AS general_election_polling_on
        FROM boundary_set_general_election_party_performances bsgepp, political_parties pp, general_elections ge
        WHERE bsgepp.political_party_id = pp.id
        AND bsgepp.general_election_id = ge.id
        AND bsgepp.boundary_set_id = #{@boundary_set.id}
        ORDER BY pp.name, ge.polling_on
          
      "
    )
    @page_title = "Boundary set for #{@boundary_set.display_title} - general election party performance"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>General election party performance</span>".html_safe
  end
end
