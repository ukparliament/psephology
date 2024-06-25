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
        ORDER BY pp.abbreviation
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
        ORDER BY politic_party_abbreviation
      "
    )
    
    # For each general election held during the duration of the boundary set ...
    @general_elections.each do |general_election|
      
      # ... we create a new array to capture the number of constituencies per political party.
      constituencies_won = []
      
      # For each boundary set general election political party performance in this boundary set.
      @party_performances.each do |party_performance|
        
        # ... if the general election the party performance was in was this general election ...
        if party_performance.general_election_id == general_election.id
          
          # ... we add the consituency won count to the array.
          constituencies_won << party_performance
        end
      end
      
      # We save the constituencies won count as an array on the general election object.
      general_election.constituencies_won = constituencies_won
    end
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - general election party performance"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>General election party performance</span>".html_safe
    
    @section = 'boundary-sets'
    @subsection = 'parties'
    @description = "Party performances in general elections in #{@boundary_set.country_name} held during the existence of the #{@boundary_set.display_title} boundary set."
    @crumb = "<li><a href='/boundary-sets'>Boundary sets</a></li>"
    @crumb += "<li><a href='/boundary-sets/#{@boundary_set.id}'>" + @boundary_set.display_title + '</a></li>'
    @crumb += '<li>Party performances</li>'
  end
end
