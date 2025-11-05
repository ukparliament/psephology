task :import_winners => :environment do

  # We find the general election.
  general_election = GeneralElection.find( GENERAL_ELECTION_ID )

  # We reset the publication state of the general election to post-election winners.
  general_election.general_election_publication_state_id = 3
  general_election.save!

  # For each row in the constituency spreadsheet ...
  CSV.foreach( "db/data/results-by-parliament/#{NEW_PARLIAMENT_NUMBER}/publication-state-tests/winners/winners.csv"  ).with_index do |row, index|
  
    # ... we skip the first row.
    next if index == 0
    
    # We store the variables we need to find the candidate.
    geographic_code = row[0].strip
    democracy_club_identifier = row[4].strip
    
    # We attempt to find the candidate.
    # We include the general election and the constituency area geographic code to ensure we match the correct record.
    candidacy = Candidacy.find_by_sql([
      "
        SELECT cand.*
        FROM candidacies cand, elections e, constituency_groups cg, constituency_areas ca
        WHERE cand.election_id = e.id
        AND e.general_election_id = ?
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.geographic_code = ?
        AND cand.democracy_club_person_identifier = ?
      ", GENERAL_ELECTION_ID, geographic_code, democracy_club_identifier
    ]).first
    
    # We store the variables we need to find the Member.
    member_mnis_id = row[5].strip
    
    # We attempt to find the Member.
    member = Member.find_by_mnis_id( member_mnis_id )
    
    # Unless we find the Member ...
    unless member
    
      # ... we store the variables we need to create the Member.
      family_name = row[2].strip
      given_name = row[3].strip
      
      # We create the Member.
      member = Member.new
      member.given_name = given_name
      member.family_name = family_name
      member.mnis_id = member_mnis_id
      member.save!
    end
    
    # We associate the candidacy with the Member.
    candidacy.member = member
    
    # We set the candidacy to to be the winning candidacy ...
    candidacy.is_winning_candidacy = true
    
    # ... with position one.
    candidacy.result_position = 1
    candidacy.save!
    
    # We store the variables we need to find the result summary.
    result_summary_text = row[6].strip
    
    # We attempt to find the result summary.
    result_summary = ResultSummary.find_by_short_summary( result_summary_text )
    
    # Unless we find the result summary.
    unless result_summary
    
      # We create it.
      result_summary = ResultSummary.new
      result_summary.short_summary = result_summary_text
      result_summary.save!
    end
    
    # We get the election the candidacy forms part of.
    election = candidacy.election
    
    # We associate the election the candidacy forms part of with the result summary.
    election.result_summary = result_summary
    election.save!
  end
end