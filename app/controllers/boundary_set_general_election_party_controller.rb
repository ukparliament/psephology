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
    
    # We get the unique set of politic parties having ever had a candidate in this boundary set.
    @unique_parties = PoliticalParty.find_by_sql(
      "
        SELECT pp.*
        FROM political_parties pp, boundary_set_general_election_party_performances bsgepp
        WHERE pp.id = bsgepp.political_party_id
        AND bsgepp.boundary_set_id = #{@boundary_set.id}
        GROUP BY pp.id
        ORDER BY pp.name
      "
    )
    
    # We get the boundary set general election political party performances in this boundary set.
    @party_performances = BoundarySetGeneralElectionPartyPerformance.find_by_sql(
      "
        SELECT
          bsgepp.*,
          pp.abbreviation AS politic_party_abbreviation,
          pp.name AS political_party_name,
          ge.polling_on AS general_election_polling_on
        FROM boundary_set_general_election_party_performances bsgepp, political_parties pp, general_elections ge
        WHERE bsgepp.political_party_id = pp.id
        AND bsgepp.boundary_set_id = #{@boundary_set.id}
        AND bsgepp.general_election_id = ge.id
        ORDER BY general_election_polling_on
      "
    )
    
    # For each unique political party ...
    @unique_parties.each do |political_party|
    
      # ... we create an empty array of party performances.
      party_performances = []
    
      # For each party performance ...
      @party_performances.each do |party_performance|
      
        # ... if the party performance is for this party ...
        if party_performance.political_party_id == political_party.id
          
          # ... we add the party performance to the performances array.
          party_performances << party_performance
        end
      end
      
      # We append the party performances array to the political party.
      political_party.party_performances = party_performances
    end
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - general election party performance"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>General election party performance</span>".html_safe
    @description = "Party performances in general elections in #{@boundary_set.country_name} held during the existence of the #{@boundary_set.display_title} boundary set."
    @crumb << { label: 'Boundary sets', url: boundary_set_list_url }
    @crumb << { label: @boundary_set.display_title, url: boundary_set_show_url( :boundary_set => @boundary_set ) }
    @crumb << { label: 'Party performances', url: nil }
    @section = 'boundary-sets'
    @subsection = 'parties'
  end
end
