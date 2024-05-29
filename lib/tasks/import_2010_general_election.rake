require 'csv'

# We set the Parliament number.
PARLIAMENT_NUMBER = 55

# We set the polling date.
POLLING_ON = '2010-05-06'

task :import_general_election_2010 => [
  :import_2010_candidacy_results,
  :import_2010_constituency_results#,
  #:populate_2010_result_positions,
  #:generate_2010_cumulative_counts,
  #:generate_2010_parliamentary_parties,
  #:assign_2010_non_party_flags_to_result_summaries,
  #:associate_2010_result_summaries_with_political_parties,
  #:generate_2010_general_election_party_performances,
  #:generate_2010_boundary_set_general_election_party_performances,
  #:generate_2010_english_region_general_election_party_performances,
  #:generate_2010_country_general_election_party_performances,
  #:infill_2010_missing_boundary_set_general_election_party_performances
]

# ## A task to import 2010 election candidacy results.
task :import_2010_candidacy_results => :environment do
  puts "importing 2010 candidacy results"
  
  # We find the general election this election forms part of.
  general_election = GeneralElection.find_by_polling_on( POLLING_ON )
  
  # For each row in the results sheet ...
  CSV.foreach( "db/data/results-by-parliament/#{PARLIAMENT_NUMBER}/general-election/candidacies.csv" ) do |row|
    
    # ... we store the values from the spreadsheet.
    candidacy_country = row[5].strip if row[5]
    candidacy_constituency_area_geographic_code = row[0].strip if row[0]
    candidacy_candidate_gender = row[14].strip if row[14]
    candidacy_candidate_mnis_member_id = row[17].strip if row[17]
    candidacy_candidate_given_name = row[12].strip.strip if row[12]
    candidacy_candidate_family_name = row[13].strip.strip if row[13]
    candidacy_candidate_is_sitting_mp = row[15].strip if row[15]
    candidacy_candidate_is_former_mp = row[16].strip if row[16]
    candidacy_vote_count = row[18].strip if row[18]
    candidacy_vote_share = row[19].strip if row[19]
    candidacy_vote_change = row[20].strip if row[20]
    
    
    
    candidacy_main_political_party_name = row[7].strip if row[7]
    candidacy_main_political_party_abbreviation = row[8].strip if row[8]
    candidacy_main_political_party_electoral_commission_id = row[9].strip if row[9]
    candidacy_main_political_party_mnis_id = row[10].strip if row[10]
    candidacy_adjunct_political_party_electoral_commission_id = row[11].strip if row[11]
    
    
    
    # We find the country.
    country = Country.find_by_name( candidacy_country )
    
    # We find the current boundary set for the country.
    boundary_set = BoundarySet.find_by_sql(
      "
        SELECT *
        FROM boundary_sets
        WHERE start_on < '#{POLLING_ON}'
        AND end_on > '#{POLLING_ON}'
        AND country_id = #{country.id}
      "
    ).first
    
    # We find the constituency_group the election is in.
    constituency_group = ConstituencyGroup.find_by_sql(
      "
        SELECT cg.*
        FROM constituency_groups cg, constituency_areas ca
        WHERE cg.constituency_area_id = ca.id
        AND ca.boundary_set_id = #{boundary_set.id}
        AND ca.geographic_code = '#{candidacy_constituency_area_geographic_code}'
      "
    ).first
    
    # We check if there's an election forming part of this general election for this constituency group.
    election = Election.find_by_sql(
      "
        SELECT e.*
        FROM elections e
        WHERE e.constituency_group_id = #{constituency_group.id}
        AND e.general_election_id = #{general_election.id}
      "
    ).first
    
    # If there's no election forming part of this general election for this constituency group ...
    unless election
      
      # ... we find the Parliament period this election was in to.
      parliament_period = ParliamentPeriod.find_by_number( PARLIAMENT_NUMBER )
      
      # ... we create the election.
      election = Election.new
      election.polling_on = POLLING_ON
      election.constituency_group = constituency_group
      election.general_election = general_election
      election.parliament_period = parliament_period
      #election.save!
    end
    
    # We find the gender of the candidate.
    gender = Gender.find_by_gender( candidacy_candidate_gender )
    
    # If the candidate has a MNIS Member ID ...
    if candidacy_candidate_mnis_member_id
      
      # ... we attempt to find the Member with this MNIS ID.
      member = Member.find_by_mnis_id( candidacy_candidate_mnis_member_id )
      
      # Unless we find the Member ...
      unless member
        
        # ... we create the Member.
        member = Member.new
        member.given_name = candidacy_candidate_given_name
        member.family_name = candidacy_candidate_family_name
        member.mnis_id = candidacy_candidate_mnis_member_id
        #member.save!
      end
    end
    
    # We create a candidacy.
    candidacy = Candidacy.new
    candidacy.candidate_given_name = candidacy_candidate_given_name
    candidacy.candidate_family_name = candidacy_candidate_family_name
    candidacy.candidate_gender = gender
    candidacy.member = member if member
    if candidacy_candidate_is_sitting_mp == 'Yes'
      candidacy.candidate_is_sitting_mp = true
    elsif candidacy_candidate_is_sitting_mp == 'No'
      candidacy.candidate_is_sitting_mp = false
    end
    if candidacy_candidate_is_former_mp == 'Yes'
      candidacy.candidate_is_former_mp = true
    elsif candidacy_candidate_is_former_mp == 'No'
      candidacy.candidate_is_former_mp = false
    end
    candidacy.election = election
    candidacy.vote_count = candidacy_vote_count
    candidacy.vote_share = candidacy_vote_share
    candidacy.vote_change = candidacy_vote_change
    
    # If the party name is Independent ...
    if candidacy_main_political_party_name == 'Independent'
      
      # ... we flag the candidacy as standing as independent.
      candidacy.is_standing_as_independent = true
      
    # Otherwise, if the party name is Speaker ...
    elsif candidacy_main_political_party_name == 'Speaker'
      
      # ... we flag the candidacy as standing as Commons Speaker.
      candidacy.is_standing_as_commons_speaker = true
      
    # Otherwise, if the candidacy has an adjunct political party certification ...
    # ... we know this is a Labour / Co-op candidacy ...
    elsif candidacy_adjunct_political_party_electoral_commission_id
      
      # ... we check if the main political party exists.
      political_party = PoliticalParty.find_by_electoral_commission_id( candidacy_main_political_party_electoral_commission_id )
      
      # If the main political party does not exist.
      unless political_party
        
        # ... we create it.
        political_party = PoliticalParty.new
        political_party.name = 'Labour'
        political_party.abbreviation = 'Lab'
        political_party.electoral_commission_id = candidacy_main_political_party_electoral_commission_id
        political_party.mnis_id = candidacy_main_political_party_mnis_id
        #political_party.save!
      end
        
      # We create a certification of the candidacy by the political party.
      certification1 = Certification.new
      certification1.candidacy = candidacy
      certification1.political_party = political_party
      #certification1.save!
      
      # We check if the adjunct political party exists.
      political_party = PoliticalParty.find_by_electoral_commission_id( candidacy_adjunct_political_party_electoral_commission_id )
      
      # If the adjunct political party does not exist.
      unless political_party
        
        # ... we create it.
        political_party = PoliticalParty.new
        political_party.name = 'Co-operative'
        political_party.abbreviation = 'Co-op'
        political_party.electoral_commission_id = candidacy_adjunct_political_party_electoral_commission_id
        #political_party.save!
      end
        
      # We create a certification of the candidacy by the political party ...
      certification2 = Certification.new
      certification2.candidacy = candidacy
      certification2.political_party = political_party
    
      # ... making it adjunct to the certification by the Labour Party.
      certification2.adjunct_to_certification_id = certification1.id
      #certification2.save!
      
    # Otherwise, if the candidacy does not have an adjunct political party certification ...
    # ... we know this is not The Speaker, not an independent candidacy and not a Labour / Co-op candidacy ...
    else
      
      # ... so we check if a political party with that name and abbreviation exists ...
      # ... because we know older political parties may not have an Electoral Commission ID.
      political_party = PoliticalParty
        .all
        .where( "name = ?", candidacy_main_political_party_name )
        .where( "abbreviation = ?", candidacy_main_political_party_abbreviation )
        .first
        
      # If the political party does not exist ...
      unless political_party
        
        # ... we create it.
        political_party = PoliticalParty.new
        political_party.name = candidacy_main_political_party_name
        political_party.abbreviation = candidacy_main_political_party_abbreviation
        political_party.electoral_commission_id = candidacy_main_political_party_electoral_commission_id
        political_party.mnis_id = candidacy_main_political_party_mnis_id
        #political_party.save!
      end
      
      # We create a certification of the candidacy by the party.
      certification = Certification.new
      certification.candidacy = candidacy
      certification.political_party = political_party
      #certification.save!
    end
    
    # We save the candidacy.
    #candidacy.save!
  end
end

# ## A task to import election constituency results.
task :import_2010_constituency_results => :environment do
  puts "importing 2010 election constituency results"
  
  # We find the general election this election forms part of.
  general_election = GeneralElection.find_by_polling_on( POLLING_ON )
  
  # For each row in the results sheet ...
  CSV.foreach( "db/data/results-by-parliament/#{PARLIAMENT_NUMBER}/general-election/constituencies.csv" ) do |row|
    
    # We store the new data we want to capture in the database.
    election_declaration_at = row[7].strip if row[7]
    election_result_type = row[11].strip if row[11]
    election_valid_vote_count = row[15].strip if row[15]
    election_invalid_vote_count = row[16].strip if row[16]
    election_majority = row[17].strip if row[17]
    electorate_count = row[14].strip if row[14]
    
    # We store the data we need to find the candidacy, quoted for SQL.
    candidacy_candidate_family_name = ActiveRecord::Base.connection.quote( row[9].strip )
    candidacy_candidate_given_name = ActiveRecord::Base.connection.quote( row[8].strip )
    constituency_area_geographic_code = ActiveRecord::Base.connection.quote( row[0] )
    
    # We find the candidacy.
    # NOTE: this works on the assumption that the name of the winning candidate standing in a given general election in a constituency with a given geographic code is unique, which appears to be true.
    candidacy = Candidacy.find_by_sql(
      "
        SELECT c.*
        FROM candidacies c, elections e, constituency_groups cg, constituency_areas ca
        WHERE c.candidate_given_name = #{candidacy_candidate_given_name}
        AND c.candidate_family_name = #{candidacy_candidate_family_name}
        AND c.election_id = e.id
        AND e.general_election_id = #{general_election.id}
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.geographic_code = #{constituency_area_geographic_code}
        ORDER BY c.vote_count DESC
      "
    )
    if candidacy != 1
      puts "oops"
      puts candidacy.size
    end
    candidacy = candidacy.first
    
    # We annotate the election results.
    #annotate_election_results( candidacy, election_result_type, election_valid_vote_count, election_invalid_vote_count, election_majority, electorate_count, election_declaration_at )
  end
end