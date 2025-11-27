GENERAL_ELECTION_ID = 6

NEW_PARLIAMENT_NUMBER = 59

OLD_PARLIAMENT_DISSOLUTION_DATE = '2024-05-30'

# ## A task to import candidacies.
task :import_candidacies => :environment do

  # We find the general election.
  general_election = GeneralElection.find( GENERAL_ELECTION_ID )

  # We reset the publication state of the general election to pre-election candidates.
  general_election.general_election_publication_state_id = 2
  general_election.save!
  
  # For each row in the candidacy spreadsheet ...
  CSV.foreach( "db/data/results-by-parliament/#{NEW_PARLIAMENT_NUMBER}/publication-state-tests/candidacies/candidacies.csv"  ).with_index do |row, index|
    
    # ... we skip the first row.
    next if index == 0
    
    # We store the constituency geographic code.
    geographic_code = row[0]
    
    # We find the election the candidacy is in.
    election = Election.find_by_sql([
      "
      SELECT e.*
      FROM elections e, constituency_groups cg, constituency_areas ca
      WHERE e.general_election_id = ?
      AND e.constituency_group_id = cg.id
      AND cg.constituency_area_id = ca.id
      AND ca.geographic_code = ?
      ", general_election.id, geographic_code
    ]).first
    
    # We store the information we need to find the candidacy.
    democracy_club_person_identifier = row[21]
    
    # We attempt to find a candidacy with this Democracy Club identifier in this election.
    candidacy = Candidacy
      .where( "election_id = ?", election.id )
      .where( "democracy_club_person_identifier = ?", democracy_club_person_identifier )
      .first
      
    # Unless we find the candidacy ...
    unless candidacy
      
      # We create a new candidacy.
      candidacy = Candidacy.new
      
      # We associate the candidacy with the election it forms part of.
      candidacy.election = election
      
      # We add the Democracy Club identifier.
      candidacy.democracy_club_person_identifier = democracy_club_person_identifier
      
      # We mark the candidacy as not notional.
      candidacy.is_notional = false
    end
    
    # We store the information we need to populate the candidacy ...
    candidate_given_name = row[12].strip
    candidate_family_name = row[13].strip
    candidate_is_sitting_mp = generate_true_false( row[15] )
    candidate_is_former_mp = generate_true_false ( row[16] )
    candidate_gender = get_gender( row[14] )
    candidate_member = find_or_create_member( row[17], candidate_given_name, candidate_family_name )
    
    # ... and their 'party'.
    candidacy_political_party_name = row[7].strip if row[7]
    candidacy_political_party_abbreviation = row[8].strip if row[8]
    candidacy_political_party_mnis_id = row[10].strip if row[10]
      
    # Setting or updating the given name of the candidate ...
    candidacy.candidate_given_name = candidate_given_name
      
    # ... and the family name of the candidate.
    candidacy.candidate_family_name = candidate_family_name
    
    # Recording if the candidate was a sitting MP ...
    candidacy.candidate_is_sitting_mp = candidate_is_sitting_mp
    
    # ... and a former MP.
    candidacy.candidate_is_former_mp = candidate_is_former_mp
    
    # We add the candidate's gender.
    candidacy.candidate_gender = candidate_gender
    
    # Associate the candidacy with its Member.
    candidacy.member = candidate_member
    
    # If the 'party' name is 'Independent' ...
    if candidacy_political_party_name == 'Independent'
    
      # ... we set the standing as independent flag to true.
      candidacy.is_standing_as_independent = true
      
    # Otherwise if the 'party' name is Speaker ...
    elsif candidacy_political_party_name == 'Speaker'
    
      # ... we set the standing as Commons Speaker flag to true.
      candidacy.is_standing_as_commons_speaker = true
    end
    
    # We save the candidacy.
    candidacy.save!
    
    # If the 'party' name is not Independent or Speaker ...
    if candidacy_political_party_name != 'Independent' and candidacy_political_party_name != 'Speaker'
    
      # ... we find or create the certifications.
      find_or_create_certification( candidacy, candidacy_political_party_name, candidacy_political_party_abbreviation, candidacy_political_party_mnis_id )
     end
  end
end

def generate_true_false( input )
  true_false = false
  true_false = true if input == 'Yes'
  true_false
end

def get_gender( gender )
  Gender.find_by_gender( gender )
end

# A method to find or create the Member for a candidacy.
def find_or_create_member( member_mnis_id, given_name, family_name )

  # We set the Member to nil.
  member = nil
  
  # If there is a Member MNIS ID ...
  if member_mnis_id
  
    # ... we attempt to find the Member.
    member = Member.find_by_mnis_id( member_mnis_id )
    
    # Unless we find the Member ...
    unless Member
    
      # ... we create the Member.
      member = Member.new
      member.given_name = given_name
      member.family_name = family_name
      member.mnis_id = member_mnis_id
      member.save!
    end
  end
  
  # We return the Member or nil.
  member
end

# A method to find or create the certifications for a candidacy.
def find_or_create_certification( candidacy, candidacy_political_party_name, candidacy_political_party_abbreviation, candidacy_political_party_mnis_id )

  # If the political party name is Labour and Co-operative.
  if candidacy_political_party_name == 'Labour and Co-operative'
  
    # ... we find the Labour Party.
    political_party = PoliticalParty.find_by_mnis_id( candidacy_political_party_mnis_id )
    
    # We attempt to find a certification by this political party of this candidacy.
    certification1 = Certification
      .where( "candidacy_id = ?", candidacy.id )
      .where( "political_party_id = ?", political_party.id )
      .where( "adjunct_to_certification_id IS NULL" )
      .first
      
    # Unless we find a certification by this political party of this candidacy ...
    unless certification1
    
      # ... we create a certification of the candidacy by the political party.
      certification1 = Certification.new
      certification1.candidacy = candidacy
      certification1.political_party = political_party
      certification1.save!
    end
    
    # We find the Co-operative Party.
    political_party = PoliticalParty.find_by_name( 'Co-operative Party' )
    
    # We attempt to find a certification by this political party of this candidacy.
    certification2 = Certification
      .where( "candidacy_id = ?", candidacy.id )
      .where( "political_party_id = ?", political_party.id )
      .where( "adjunct_to_certification_id IS NOT NULL" )
      .first
      
    # Unless we find a certification by this political party of this candidacy ...
    unless certification2
  
      # ... we create a certification of the candidacy by the political party.
      certification2 = Certification.new
      certification2.candidacy = candidacy
      certification2.political_party = political_party
      certification2.adjunct_to_certification_id = certification1.id
      certification2.save!
    end
    
  # Otherwise, if the political party name is not 'Labour and Co-operative' ...
  else
  
    # ... we attempt to find the political party.
    political_party = PoliticalParty.find_by_mnis_id( candidacy_political_party_mnis_id )
    
    # Unless we find the political party ...
    unless political_party
    
      # ... we create the political party.
      political_party = PoliticalParty.new
      political_party.name = candidacy_political_party_name
      political_party.abbreviation = candidacy_political_party_abbreviation
      political_party.mnis_id = candidacy_political_party_mnis_id
      political_party.save!
    end
    
    # We attempt to find a certification by this political party of this candidacy.
    certification = Certification
      .where( "candidacy_id = ?", candidacy.id )
      .where( "political_party_id = ?", political_party.id )
      .where( "adjunct_to_certification_id IS NULL" )
      .first
      
    # Unless we find a certification by this political party of this candidacy ...
    unless certification
    
      # We create a certification of the candidacy by the political party.
      certification = Certification.new
      certification.candidacy = candidacy
      certification.political_party = political_party
      certification.save!
    end
  end
end