# ## A task to import data for the general election into Parliament 60.
task :import_parliament_60 => [
  :report_parliament_60_import_start_time,
  :import_parliament_60_constituencies,
  :import_parliament_60_candidacies,
  :apply_result_positions_for_parliament_60_candidacies,
  :mark_parliament_60_winning_parties_as_parliamentary,
  :report_parliament_60_import_end_time
]

# ## A task to report the start time of the import.
task :report_parliament_60_import_start_time => :environment do
  print "\a"
  puts "Imported started at #{Time.now.strftime( '%H:%M:%S' )}"
end

# ## A task to import constituency level data for Parliament 60.
task :import_parliament_60_constituencies => :environment do
  puts "importing Parliament 60 constituency data"
  
  # We set the path to the Parliament 60 constituencies CSV.
  parliament_60_constituencies_csv = 'db/data/results-by-parliament/60/general-election/constituencies.csv'
  
  # For each row in the sheet ...
  CSV.foreach( parliament_60_constituencies_csv ).with_index do |row, index|
  
    # ... we skip the first row
    next if index == 0
    
    # We store the Election Manager election ID.
    election_manager_election_id = row[0]
    
    # We attempt to find the election by its Election Manager ID.
    election = Election.find_by_election_manager_id( election_manager_election_id )
    
    # Unless we find an election ...
    unless election
    
      # ... we store the geographic code of the constituency area.
      constituency_area_geographic_code = row[2]
      
      # We attempt to find an election in this constituency area for this Parliament.
      election = Election.find_by_sql(
        [
          "
            SELECT e.*
            FROM elections e, constituency_groups cg, constituency_areas ca
            WHERE e.parliament_period_id = 60
            AND e.constituency_group_id = cg.id
            AND cg.constituency_area_id = ca.id
            AND ca.geographic_code = ?
          ", constituency_area_geographic_code
        ]
      ).first
      
      # We assign the Election Manager election ID to the election.
      election.election_manager_id = election_manager_election_id
      election.save!
    end
    
    # We store the election state label.
    election_state_label = row[1].strip
    
    # We attempt to find an election state with this label.
    election_state = ElectionState.find_by_label( election_state_label )
    
    # If the election is not in this state.
    if election.election_state_id != election_state.id
    
      # ... we set the election to the new election state.
      election.election_state_id = election_state.id
      election.save!
    end
    
    # If the state of the election_state is 3 - Winners only - or 4 - Full results ...
    if election_state.state >= 3
    
      # ... we store the short and long summaries.
      short_summary = row[12]
      long_summary = row[13]
      
      # We attempt to find a result summary with this short summary.
      result_summary = ResultSummary.find_by_short_summary( short_summary )
      
      # Unless we find a result summary with this short summary ...
      unless result_summary
      
        # ... we create a new result summary with these long and short summaries.
        result_summary = ResultSummary.new
        result_summary.short_summary = short_summary
        result_summary.summary = long_summary
        result_summary.save!
      end
      
      # We associate the election with this result summary.
      election.result_summary = result_summary
      election.save!
    end
    
    # If the state of the election state is 4 - Full results ...
    if election_state.state == 4
    
      # ... we store the declaration time, valid vote count, invalid vote count and majority.
      declaration_at = row[8]
      valid_vote_count = row[17]
      invalid_vote_count = row[18]
      majority = row[19]
      
      # We update these numbers for the election.
      election.declaration_at = declaration_at
      election.valid_vote_count = valid_vote_count
      election.invalid_vote_count = invalid_vote_count
      election.majority = majority
      election.save!
      
      # We store the electorate.
      electorate_population_count = row[16]
      
      # If the election has an assigned electorate ...
      if election.electorate_id
      
        # ... we find the electorate ...
        electorate = Electorate.find( election.electorate_id )
        
        # ... and update its population count.
        electorate.population_count = electorate_population_count
        electorate.save!
      
      # Otherwise, if the election does not have an assigned electorate ...
      else
      
        # ... we create a new electorate ...
        electorate = Electorate.new
        electorate.population_count = electorate_population_count
        electorate.constituency_group = election.constituency_group
        electorate.save!
        
        # ... and link the election to that electorate.
        election.electorate = electorate
        election.save!
      end
    end
  end
end

# ## A task to import candidacy level data for Parliament 60.
task :import_parliament_60_candidacies => :environment do
  puts "importing Parliament 60 candidacy data"
  
  # We set the path to the Parliament 60 candidacies CSV.
  parliament_60_candidacies_csv = 'db/data/results-by-parliament/60/general-election/candidacies.csv'
  
  # For each row in the sheet ...
  CSV.foreach( parliament_60_candidacies_csv ).with_index do |row, index|
  
    # ... we skip the first row
    next if index == 0
    
    # We store the Election Manager election ID.
    election_manager_election_id = row[0]
    
    # We find the election by its Election Manager ID.
    election = Election.find_by_election_manager_id( election_manager_election_id )
    
    # We find the state of the election.
    election_state = ElectionState.find( election.election_state_id )
    
    # If the election is in a state of Candidates only, Winners only or Full results ...
    if election_state.state > 1
    
      # ... we call a method to import or update the candidates, passing it the row.
      create_or_update_candidacies_for_parliament_60_general_election( row )
      
      # If the election is in a state of Winners only or Full results ...
      if election_state.state > 2
      
        # ... we store the Election Manager candidacy ID.
        candidacy_id = row[1]
        
        # We find the candidacy with this Election Manager ID.
        candidacy = Candidacy.find_by_election_manager_id( candidacy_id )
        
        # If the winning candidacy column is marked as 'No' ...
        if row[26] == 'No'
          
          # ... we set is winning candidacy to false.
          is_winning_candidacy = false
          
        # Otherwise, if the winning candidacy column is marked as 'Yes'
        else
          
          # ... we set is winning candidacy to true.
          is_winning_candidacy = true
        end
        
        # We update the candidacy to capture whether it's the winning candidacy or not.
        candidacy.is_winning_candidacy = is_winning_candidacy
        candidacy.save!
      end
      
      # If the election is in a state of Full results ...
      if election_state.state > 3
      
        # ... we store the vote count, vote change and vote share numbers.
        vote_count = row[27]
        vote_change = row[28]
        vote_share = row[29]
        
        # We update the candidacy with these numbers.
        candidacy.vote_count = vote_count
        candidacy.vote_change = vote_change
        candidacy.vote_share = vote_share
        candidacy.save!
      end
    end
  end
end

# ## A task to apply result positions to candidacies in Parliament 60.
task :apply_result_positions_for_parliament_60_candidacies => :environment do
  puts "applying result positions to candidacies in Parliament 60"
  
  # We get all elections in the Parliament 60 general election with full results.
  elections = Election.find_by_sql(
    [
      "
        SELECT e.*
        FROM elections e, election_states es
        WHERE e.parliament_period_id = 60
        AND e.general_election_id IS NOT NULL
        AND e.election_state_id = es.id
        AND es.label = ?
      ", 'Full results'
    ]
  )
  
  # For each election in the Parliament 60 general election with full results ...
  elections.each do |election|
  
    # ... we set the result position to zero.
    result_position = 0
  
    # ... we get all the candidacies in the election ordered by vote count descending.
    candidacies = Candidacy.where( 'election_id = ?', election.id ).order( 'vote_count DESC' )
    
    # For each candidacy.
    candidacies.each do |candidacy|
    
      # ... we increment the result position ...
      result_position += 1
      
      # ... and save on the candidacy.
      candidacy.result_position = result_position
      candidacy.save!
    end
  end        
end

# A task to mark winning parties in the Parliament 60 general election as parliamentary.
task :mark_parliament_60_winning_parties_as_parliamentary => :environment do
  puts "marking winning parties in the Parliament 60 general election as parliamentary"
  
  # We find all parties who've won an election in the general election for Parliament 60 but are not marked as parliamentary parties.
  parties = PoliticalParty.find_by_sql(
    "
      SELECT pp.*
      FROM political_parties pp, certifications cert, candidacies cand, elections elec
      WHERE pp.id = cert.political_party_id
      AND cert.adjunct_to_certification_id IS NULL
      AND cert.candidacy_id = cand.id
      AND cand.is_winning_candidacy IS TRUE
      AND cand.election_id = elec.id
      AND elec.general_election_id IS NOT NULL
      AND elec.parliament_period_id = 60
      AND pp.has_been_parliamentary_party IS FALSE
      GROUP BY pp.id
    "
  )
  
  # For each party who won an election in the general election for Parliament 60 but are not marked as parliamentary parties ...
  parties.each do |party|
  
    # ... we set the has been parliamentary party flag to true.
    party.has_been_parliamentary_party = true
    party.save!
  end
end

# ## A task to report the end time of the import.
task :report_parliament_60_import_end_time => :environment do
  puts "Imported ended at #{Time.now.strftime( '%H:%M:%S' )}"
  print "\a"
  print "\a"
end

# A method to create or update candidacies for the Parliament 60 general election.
def create_or_update_candidacies_for_parliament_60_general_election( row )

  # We store the Election Manager candidacy ID.
  election_manager_candidacy_id = row[1]
  
  # We attempt to find the candidacy by its Election Manager ID.
  candidacy = Candidacy.find_by_election_manager_id( election_manager_candidacy_id )
  
  # Unless we find a candidacy with this Election Manager ID ...
  unless candidacy
    
    # ... we store the Election Manager election ID.
    election_manager_election_id = row[0]
    
    # We find the election by its Election Manager ID.
    election = Election.find_by_election_manager_id( election_manager_election_id )
    
    # We create the candidacy.
    candidacy = Candidacy.new
    candidacy.election_manager_id = election_manager_candidacy_id
    candidacy.election = election
    candidacy.save!
  end
  
  # We store the candidate gender.
  candidate_gender = row[22]
  
  # We find the gender.
  gender = Gender.find_by_gender( candidate_gender )
  
  # We store the candidate given name, candidate family name, candidate is sitting MP, candidate is former MP, candidate is standing as independent and candidate is standing as Speaker.
  candidate_given_name = row[20]
  candidate_family_name = row[21]
  candidate_is_sitting_mp = row[23]
  candidate_is_former_mp = row[24]
  is_standing_as_independent = row[18]
  is_standing_as_commons_speaker = row[19]
  
  # If the candidacy has a MNIS ID ...
  unless row[25].blank?
  
    # ... we store the Member MNIS ID.
    member_mnis_id = row[25]
  
    # We attempt to find a Member with this MNIS ID.
    member = Member.find_by_mnis_id( member_mnis_id )
    
    # Unless we find a Member with this MNIS ID ...
    unless member
    
      # ... we create a new Member.
      member = Member.new
      member.given_name = candidate_given_name
      member.family_name = candidate_family_name
      member.mnis_id = member_mnis_id
      member.save!
    end
  end
  
  # We update the candidacy with new values.
  candidacy.candidate_given_name = candidate_given_name
  candidacy.candidate_family_name = candidate_family_name
  if candidate_is_sitting_mp == 'Yes'
    candidacy.candidate_is_sitting_mp = true
  else
    candidacy.candidate_is_sitting_mp = false
  end
  if candidate_is_former_mp == 'Yes'
    candidacy.candidate_is_former_mp = true
  else
    candidacy.candidate_is_former_mp = false
  end
  if is_standing_as_independent == 'Yes'
    candidacy.is_standing_as_independent = true
  else
    candidacy.is_standing_as_independent = false
  end
  if is_standing_as_commons_speaker == 'Yes'
    candidacy.is_standing_as_commons_speaker = true
  else
    candidacy.is_standing_as_commons_speaker = false
  end
  candidacy.candidate_gender_id = gender.id
  candidacy.member = member if member
  candidacy.save!
  
  # We call a method to create or update certifications for the Parliament 60 general election.
  create_or_update_certifications_for_parliament_60_general_elections( candidacy, row )
end

# A method to create or update certifications for the Parliament 60 general election.
def create_or_update_certifications_for_parliament_60_general_elections( candidacy, row )

  # We create or update the main certifications for the Parliament 60 general election.
  create_or_update_main_certifications_for_parliament_60_general_elections( candidacy, row )

  # We create or update the adjunct certifications for the Parliament 60 general election.
  create_or_update_adjunct_certifications_for_parliament_60_general_elections( candidacy, row )
end

# A method to create or update main certifications for the Parliament 60 general election.
def create_or_update_main_certifications_for_parliament_60_general_elections( candidacy, row )

  # We attempt to find the main certification for the candidacy.
  main_certification = Certification
    .where( 'candidacy_id = ?', candidacy.id )
    .where( 'adjunct_to_certification_id IS NULL')
    .first
    
  # We store the main party MNIS ID.
  main_party_mnis_id = row[12] unless row[12].blank?
  

  # If there is a main party MNIS ID ...
  if main_party_mnis_id
  
    # ... we attempt to find the party with that MNIS ID.
    political_party = PoliticalParty.find_by_mnis_id( main_party_mnis_id )
    
    # Unless we find the political party ...
    unless political_party
    
      # ... we store the party name, abbreviation and MNIS ID.
      party_name = row[10].strip
      party_abbreviation = row[11].strip
      party_mnis_id = row[12]
    
      # ... we create the new political party.
      political_party = PoliticalParty.new
      political_party.name = party_name
      political_party.abbreviation = party_abbreviation
      political_party.mnis_id = party_mnis_id
      political_party.save!
    end
    
    # If there's a main certification ...
    if main_certification
    
      # ... if that main certification is by the same party ...
      if main_certification.political_party_id == political_party.id
      
        # ... nothing has changed, so we do nothing.
      
      # Otherwise, if that main certification is to a different political party ...
      else
      
        # ... we call a method to destroy the existing main certification ...
        destroy_main_certification( main_certification )
        
        # ... and create a new main certification.
        certification = Certification.new
        certification.candidacy = candidacy
        certification.political_party = political_party
        certification.save!
      end
      
    # Otherwise, if there is no main party certification ...
    else
        
      # ... and create one.
      certification = Certification.new
      certification.candidacy = candidacy
      certification.political_party = political_party
      certification.save!
    end
    
  # Otherwise, if there is no main party MNIS ID ...
  else
  
    # ... if there is a main certification ...
    if main_certification
    
      # ... we call a method to destroy the main certification.
      destroy_main_certification( main_certification )
    end
  end
end

# A method to destroy a main certification and any adjunct certification.
def destroy_main_certification( main_certification )

  # We attempt to find any adjunct certification to the main certification.
  adjunct_certification = Certification.find_by_adjunct_to_certification_id( main_certification )
  
  # If we find any adjunct certification to the main certification ...
  if adjunct_certification
  
    # ... we destroy it.
    adjunct_certification.destroy!
  end
  
  # We destroy the main certification.
  main_certification.destroy!
end

# A method to create or update adjunct certifications for the Parliament 60 general election.
def create_or_update_adjunct_certifications_for_parliament_60_general_elections( candidacy, row )

  # We store the adjunct party name.
  adjunct_party_name = row[14] if row[14]
  
  # If there is an adjunct party name ...
  if adjunct_party_name
  
    # ... if the adjunct party name is 'Co-operative Party' ...
    if adjunct_party_name == 'Co-operative Party'
    
      # ... we find the Co-operative Party.
      adjunct_party = PoliticalParty.find_by_name( 'Co-operative Party' )
      
    # Otherwise, if the adjunct party name is not 'Co-operative Party' ...
    else
    
      # ... we store the MNIS ID of the adjunct political party.
      adjunct_party_mnis_id = row[16]
    
      # ... we find the adjunct political party.
      adjunct_party = PoliticalParty.find_by_mnis_id( adjunct_party_mnis_id )
      
      # If we fail to find the adjunct political party ...
      unless adjunct_party
      
        # ... we store the adjunct political party abbreviation.
        adjunct_party_abbreviation = row[15]
        
        # ... we create it.
        adjunct_party = PoliticalParty.new
        adjunct_party.name = adjunct_party_name
        adjunct_party.abbreviation = adjunct_party_abbreviation
        adjunct_party.mnis_id = adjunct_party_mnis_id
        adjunct_party.save!
      end
    end
  end
  
  # We attempt to find an adjunct party certification for this candidacy.
  adjunct_certification = Certification
    .where( 'adjunct_to_certification_id IS NOT NULL' )
    .where( 'candidacy_id = ?', candidacy.id )
    .first
    
  # If the candidacy has an adjunct party ...
  if adjunct_party
  
    # ... if the candidacy has an adjunct certification ...
    if adjunct_certification
    
      # ... if the adjunct party is the same as the party of the adjunct certification ...
      if adjunct_party.id == adjunct_certification.political_party_id
      
        # ... nothing has changed, so we do nothing.
      
      # Otherwise, if the adjunct party is not the same as the party of the adjunct certification ...
      else
      
        # ... we destroy the old adjunct certification.
        adjunct_certification.destroy!
        
        # We find the main certification for the candidacy.
        main_certification = Certification
          .where( 'candidacy_id = ?', candidacy.id )
          .where( 'adjunct_to_certification_id IS NULL' )
          .first
          
        # We create a new adjunct certification.
        adjunct_certification = Certification.new
        adjunct_certification.candidacy = candidacy
        adjunct_certification.political_party = adjunct_party
        adjunct_certification.adjunct_to_certification_id = main_certification.id
        adjunct_certification.save!
      end
      
    # Otherwise, if there is no adjunct certification ...
    else
    
      # ... we find the main certification for the candidacy.
      main_certification = Certification
        .where( 'candidacy_id = ?', candidacy.id )
        .where( 'adjunct_to_certification_id IS NULL' )
        .first
    
      # We create a new adjunct certification.
      adjunct_certification = Certification.new
      adjunct_certification.candidacy = candidacy
      adjunct_certification.political_party = adjunct_party
      adjunct_certification.adjunct_to_certification_id = main_certification.id
      adjunct_certification.save!
    end
    
  # Otherwise, if the candidacy does not have an adjunct party ...
  else
  
    # ... if the candidacy has an adjunct certification ...
    if adjunct_certification
    
      # ... we destroy the adjunct certification.
      adjunct_certification.destroy!
    end
  end
end