require 'csv'

# We set the Parliament number.
PARLIAMENT_NUMBER = 55

# We set the polling date.
POLLING_ON = '2010-05-06'

task :import_general_election_2010 => [
  :report_start_time,
  :import_2010_candidacy_results,
  :import_2010_constituency_results,
  :populate_2010_result_positions,
  :generate_2010_cumulative_counts,
  :assign_2010_non_party_flags_to_result_summaries,
  :associate_2010_result_summaries_with_political_parties,
  :populate_expanded_result_summaries_2010,
  :generate_2010_general_election_party_performances,
  :generate_2010_parliamentary_parties,
  :infill_2010_general_election_party_performances,
  :generate_2010_country_general_election_party_performances,
  :generate_2010_english_region_general_election_party_performances,
  :generate_2010_boundary_set_general_election_party_performances,
  :infill_2010_missing_boundary_set_general_election_party_performances,
  :report_end_time
]

# ## A task to report the start time.
task :report_start_time => :environment do
  puts "import started at #{Time.now}"
end

# ## A task to import 2010 election candidacy results.
task :import_2010_candidacy_results => :environment do
  puts "importing 2010 candidacy results"
  
  # This task creates records for:
  # * elections
  # * members
  # * candidacies
  # * political_parties
  # * certifications
  
  # It populates:
  # * election.polling_on
  # * election.constituency_group_id
  # * election.general_election_id
  # * election.parliament_period_id
  # * member.given_name
  # * member.family_name
  # * member.mnis_id
  # * candidacy.candidate_given_name
  # * candidacy.candidate_family_name
  # * candidacy.candidate_gender_id
  # * candidacy.member_id
  # * candidacy.candidate_is_former_mp
  # * candidacy.candidate_is_sitting_mp
  # * candidacy.election_id
  # * candidacy.vote_count
  # * candidacy.vote_share
  # * candidacy.vote_change
  # * candidacy.is_standing_as_independent
  # * candidacy.is_standing_as_commons_speaker
  # * political_party.name
  # * political_party.abbreviation
  # * political_party.electoral_commission_id
  # * political_party.mnis_id
  # * certification.candidacy_id
  # * certification.political_party_id
  # * certification.adjunct_to_certification_id
  
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
    
    # We find the constituency_group the election is in.
    # The query includes the boundary set, because the ONS reused some constituency area geographic codes from the 2005 boundary set in the 2024 boundary set.
    constituency_group = ConstituencyGroup.find_by_sql(
      "
        SELECT cg.*
        FROM constituency_groups cg, constituency_areas ca, boundary_sets bs, countries c
        WHERE cg.constituency_area_id = ca.id
        AND ca.geographic_code = '#{candidacy_constituency_area_geographic_code}'
        AND ca.boundary_set_id = bs.id
        AND bs.start_on < '#{POLLING_ON}'
        AND bs.end_on > '#{POLLING_ON}'
        AND bs.country_id = c.id
        AND c.name = '#{candidacy_country}'
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
      election.save!
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
        member.save!
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
        political_party.save!
      end
        
      # We create a certification of the candidacy by the political party.
      certification1 = Certification.new
      certification1.candidacy = candidacy
      certification1.political_party = political_party
      certification1.save!
      
      # We check if the adjunct political party exists.
      political_party = PoliticalParty.find_by_electoral_commission_id( candidacy_adjunct_political_party_electoral_commission_id )
      
      # If the adjunct political party does not exist.
      unless political_party
        
        # ... we create it.
        political_party = PoliticalParty.new
        political_party.name = 'Co-operative'
        political_party.abbreviation = 'Co-op'
        political_party.electoral_commission_id = candidacy_adjunct_political_party_electoral_commission_id
        political_party.save!
      end
        
      # We create a certification of the candidacy by the political party ...
      certification2 = Certification.new
      certification2.candidacy = candidacy
      certification2.political_party = political_party
    
      # ... making it adjunct to the certification by the Labour Party.
      certification2.adjunct_to_certification_id = certification1.id
      certification2.save!
      
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
        political_party.save!
      end
      
      # We create a certification of the candidacy by the party.
      certification = Certification.new
      certification.candidacy = candidacy
      certification.political_party = political_party
      certification.save!
    end
    
    # We save the candidacy.
    candidacy.save!
  end
end

# ## A task to import election constituency results.
task :import_2010_constituency_results => :environment do
  puts "importing 2010 election constituency results"
  
  # This task creates records for:
  # * results_summaries
  # * electorates
  
  # It populates:
  # * candidacy.is_winning_candidacy
  # * result_summary.short_summary
  # * electorate.population_count
  # * electorate.constituency_group_id
  # * election.valid_vote_count
  # * election.invalid_vote_count
  # * election.majority
  # * election.result_summary_id
  # * election.electorate_id
  # * election.election.declaration_at
  
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
    # NOTE: this works on the assumption that the name of the winning candidate standing in a given election in a given general election in a constituency with a given geographic code is unique, which so far appears to be true.
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
    
    # If there is not exactly one candidacy matching the candidate names in the election ...
    if candidacy.size != 1
      
      # ... we raise a warning.
      # This is a name match check to capture occasions on which the candidate name in the candidates sheet does not match the name in the constiuency sheet, for example: a candidate named Bill in the candidates CSV being named as William in the constituency CSV.
      puts "candidacy for #{candidacy_candidate_given_name} #{candidacy_candidate_family_name} in #{constituency_area_geographic_code} not found"
    end
    
    # We get the first, and only, candidacy.
    candidacy = candidacy.first
    
    # We annotate the election results.
    # We use a method defined in the setup script.
    annotate_election_results( candidacy, election_result_type, election_valid_vote_count, election_invalid_vote_count, election_majority, electorate_count, election_declaration_at )
  end
end

# ## A task to populate result positions on candidacies for the 2010 general election.
task :populate_2010_result_positions => :environment do
  puts "populating result positions on candidacies"
  
  # This task populates:
  # * candidacy.result_position
  
  # We find the general election.
  general_election = GeneralElection.find_by_polling_on( POLLING_ON )
  
  # For each election in the general election ...
  general_election.elections.each do |election|
    
    # ... we set the result position to zero.
    result_position = 0
    
    # For each candidacy result in the election ...
    election.results.each do |result|
      
      # ... we increment the result position ...
      result_position += 1
      
      # ... and save the result position on the candidacy.
      result.result_position = result_position
      result.save!
    end
  end
end

# ## A task to generate general election cumulative counts.
task :generate_2010_cumulative_counts => :environment do
  puts "generating general election cumulative counts"
  
  # This task populates:
  # * general_election.valid_vote_count
  # * general_election.invalid_vote_count
  # * general_election.electorate_population_count
  
  # We find the general election.
  general_election = GeneralElection.find_by_polling_on( POLLING_ON )
  
  # We set the valid vote count, the invalid vote count and the electorate population count to zero.
  valid_vote_count = 0
  invalid_vote_count = 0
  electorate_population_count = 0
    
  # For each election in the general election ...
  general_election.elections.each do |election|
      
    # ... we add the valid vote count, invalid vote count and electorate population count.
    valid_vote_count += election.valid_vote_count
    invalid_vote_count += election.invalid_vote_count if election.invalid_vote_count
    electorate_population_count += election.electorate_population_count
  end
    
  # We save the cumulative counts.
  general_election.valid_vote_count = valid_vote_count
  general_election.invalid_vote_count = invalid_vote_count
  general_election.electorate_population_count = electorate_population_count
  general_election.save!
end

# ## A take to assign non-party flags - Speaker and Independent - to result summaries.
task :assign_2010_non_party_flags_to_result_summaries => :environment do
  puts "assigning non-party flags - Speaker and Independent - to result summaries"
  
  # This task populates:
  # * result_summary.is_from_commons_speaker
  # * result_summary.is_to_commons_speaker
  # * result_summary.is_from_independent
  # * result_summary.is_to_independent
  
  # We know it's possible that the 2010 general election saw the Speaker or an independent candidate gain from or lose to a party that they did not gain from or lose to in the 2015 - 2019 general elections. Therefore, we need to repopulate the to and from booleans.
  # 2015 - 2019 result summaries - including those reused in 2010 - will all have summary text, so we get all result summaries with no summary text.
  result_summaries = ResultSummary.all.where( 'summary IS NULL' )
  
  # For each result summary ...
  result_summaries.each do |result_summary|
    
    # ... we want to deal with Labour / Co-op as Labour, so we remove any mention of ' Coop'.
    result_summary.short_summary.gsub!( ' Coop', '' )
    
    # If the short summary is two words long ...
    if result_summary.short_summary.split( ' ' ).size == 2
      
      # ... we know this is a holding party.
      # If the first word indicates Commons Speaker ...
      if result_summary.short_summary.split( ' ' ).first == 'Spk'
        
        # ... we update the result summary to say Speaker holding.
        result_summary.is_from_commons_speaker = true
        result_summary.is_to_commons_speaker = true
        result_summary.save!
      
      # Otherwise, if the first word indicates Independent ...
      elsif result_summary.short_summary.split( ' ' ).first == 'Ind'
        
        # ... we update the result summary to say Independent holding.
        result_summary.is_from_independent = true
        result_summary.is_to_independent = true
        result_summary.save!
      end
      
    # Otherwise, if the short summary is four words long ...
    elsif result_summary.short_summary.split( ' ' ).size == 4
      
      # ... we know this is a gaining party.
      # If the first word indicates Commons Speaker ...
      if result_summary.short_summary.split( ' ' ).first == 'Spk'
        
        # ... we update the result summary to say Speaker gaining.
        result_summary.is_to_commons_speaker = true
        result_summary.save!
      
      # Otherwise, if the first word indicates Independent ...
      elsif result_summary.short_summary.split( ' ' ).first == 'Ind'
        
        # ... we update the result summary to say Independent gaining.
        result_summary.is_to_independent = true
        result_summary.save!
      end
      
      # If the last word indicates Commons Speaker ...
      if result_summary.short_summary.split( ' ' ).last == 'Spk'
        
        # ... we update the result summary to say Speaker losing.
        result_summary.is_from_commons_speaker = true
        result_summary.save!
      
      # Otherwise, if the last word indicates Independent ...
      elsif result_summary.short_summary.split( ' ' ).last == 'Ind'
        
        # ... we update the result summary to say Independent losing.
        result_summary.is_from_independent = true
        result_summary.save!
      end
    end
  end
end

# ## A task to associate result summaries with political parties.
task :associate_2010_result_summaries_with_political_parties => :environment do
  puts "associating result summaries with political parties"
  
  # This task populates:
  # * result_summary.from_political_party_id
  # * result_summary.to_political_party_id
  
  # We know it's possible that the 2010 general election saw a candidacy certified by a party gain from or lose to a party that they did not gain from or lose to in the 2015 - 2019 general elections, or hold a constituency they did not hold in the 2015 - 2019 general elections. Therefore, we need to repopulate the from political party and to political party fields.
  # 2015 - 2019 result summaries - including those reused in 2010 - will all have summary text, so we get all result summaries with no summary text.
  result_summaries = ResultSummary.all.where( 'summary IS NULL' )
  
  # For each result summary ....
  result_summaries.each do |result_summary|
    
    # ... we want to deal with Labour / Co-op as Labour, so we remove any mention of ' Coop'.
    result_summary.short_summary.gsub!( ' Coop', '' )
    
    # If the short summary is two words long ...
    if result_summary.short_summary.split( ' ' ).size == 2
      
      # ... it must be a holding.
      # Unless the result summary is from the Commons Speaker or from an independent.
      unless result_summary.is_from_commons_speaker == true || result_summary.is_from_independent == true
        
        # We get the party abbreviation ...
        party_abbreviation = result_summary.short_summary.split( ' ' ).first
      
        # ... and attempt to find the political party.
        holding_political_party = PoliticalParty.find_by_abbreviation( party_abbreviation )
      
        # We associate the result summary with the political party.
        result_summary.from_political_party_id = holding_political_party.id
        result_summary.to_political_party_id = holding_political_party.id
      end   
      
    # Otherwise, if the short summary is four words long ...
    elsif result_summary.short_summary.split( ' ' ).size == 4
      
      # ... it must be a gain from.
      # Unless the result summary is a gain by the Commons Speaker or by an independent.
      unless result_summary.is_to_commons_speaker == true || result_summary.is_to_independent == true
        
        # ... we get the gaining party abbreviation ...
        gaining_party_abbreviation = result_summary.short_summary.split( ' ' ).first
      
        # ... and attempt to find the political party.
        gaining_political_party = PoliticalParty.find_by_abbreviation( gaining_party_abbreviation )
      
        # We associate the result summary with the gaining political party.
        result_summary.to_political_party_id = gaining_political_party.id
      end
      
      # Unless the result summary is a loss by the Commons Speaker or by an independent ...
      unless result_summary.is_from_commons_speaker == true || result_summary.is_from_independent == true
      
        # ... we get the losing party abbreviation ...
        losing_party_abbreviation = result_summary.short_summary.split( ' ' ).last
      
        # ... and attempt to find the political party.
        losing_political_party = PoliticalParty.find_by_abbreviation( losing_party_abbreviation )
        
        # We associate the result summary with the losing political party.
        result_summary.from_political_party_id = losing_political_party.id
      end
    end
    
    # We save the result summary.
    result_summary.save!
  end
end

# ## A task to populate expanded result summaries with political parties.
task :populate_expanded_result_summaries_2010 => :environment do
  
  # This task populates:
  # * result_summary.summary
  
  # We find any result summaries with no summary text.
  result_summaries = ResultSummary.where( 'summary IS NULL')
  
  # For each result summary with no summary text ...
  result_summaries.each do |result_summary|
    
    # ... we create a string to hold the summary text.
    summary = ''
    
    # If the result summary is a gain ...
    if result_summary.is_gain?
      
      # ... if the result summary is to the speaker ...
      if result_summary.is_to_commons_speaker
        
        # ... we add speaker gain from to the summary text.
        summary += 'Speaker gain from '
        
      # Otherwise, if the result summary is to an independent ...
      elsif result_summary.is_to_independent
        
        # ... we add independent gain from to the summary text.
        summary += 'Independent gain from '
        
      # Otherwise, the result summary must be to a party, so we add the party name and gain from to the summary text.
      else
        summary += result_summary.to_political_party.name + ' gain from '
      end
      
      # If the result summary is from the speaker ...
      if result_summary.is_from_commons_speaker
        
        # ... we add speaker to the summary text.
        summary += 'Speaker'
        
      # Otherwise, if the result summary is from an independent ...
      elsif result_summary.is_from_independent
        
        # ... we add independent to the summary text.
        summary += 'Independent'
        
      # Otherwise, the result summary must be to a party, so we we add the party name to the summary text.
      else
        summary += result_summary.from_political_party.name
      end

    # Otherwise, the result summary must be a hold.
    else
      
      # If the result summary is to the speaker ...
      if result_summary.is_to_commons_speaker
        
        # ... we add speaker hold to the summary text.
        summary += 'Speaker hold'
        
      # Otherwise, if the result summary is to an independent ...
      elsif result_summary.is_to_independent
        
        # ... we add independent hold to the summary text.
        summary += 'Independent hold '
        
      # Otherwise, the result summary must be to a party, so we add the party name and hold to the summary text.
      else
        summary += result_summary.to_political_party.name + ' hold '
      end
    end
    
    # We add the summary to the result summary and save it.
    result_summary.summary = summary
    result_summary.save!
  end
end

# ## A task to generate general election party performances.
task :generate_2010_general_election_party_performances => :environment do
  puts "generating general election party performances"
  
  # This task creates records for:
  # * general_election_party_performances
  
  # It populates:
  # * general_election_party_performance.general_election_id
  # * general_election_party_performance.political_party_id
  # * general_election_party_performance.constituency_contested_count
  # * general_election_party_performance.constituency_won_count
  # * general_election_party_performance.cumulative_vote_count
  # * general_election_party_performance.cumulative_valid_vote_count
  
  # We get the general election.
  general_election = GeneralElection.find_by_polling_on( POLLING_ON )
  
  # We get all the political parties having certified candidacies in elections in the general election.
  political_parties = PoliticalParty.find_by_sql(
    "
    SELECT pp.*
    FROM political_parties pp, certifications cert, candidacies cand, elections e
    WHERE pp.id = cert.political_party_id
    AND cert.adjunct_to_certification_id IS NULL
    AND cert.candidacy_id = cand.id
    AND cand.election_id = e.id
    AND e.general_election_id = #{general_election.id}
    GROUP BY pp.id
    ORDER BY pp.name;
    "
  )
  
  # For each political party ...
  political_parties.each do |political_party|
      
    # ... we attempt to find the general election party performance for this party.
    general_election_party_performance = GeneralElectionPartyPerformance
      .all
      .where( "general_election_id = ?", general_election.id )
      .where( "political_party_id = ?", political_party.id )
      .first
    
    # Unless we find the general election party performance for this party ...
    unless general_election_party_performance
      
      # ... we create a general election party performance with all counts set to zero.
      general_election_party_performance = GeneralElectionPartyPerformance.new
      general_election_party_performance.general_election = general_election
      general_election_party_performance.political_party = political_party
      general_election_party_performance.constituency_contested_count = 0
      general_election_party_performance.constituency_won_count = 0
      general_election_party_performance.cumulative_vote_count = 0
      general_election_party_performance.cumulative_valid_vote_count = 0
    end
    
    # For each election forming part of the general election ...
    general_election.elections.each do |election|
      
      # ... if a candidacy representing the political party is in the election ...
      if political_party.represented_in_election?( election )
        
        # ... we increment the constituency contested count.
        general_election_party_performance.constituency_contested_count += 1
        
        # We add the vote count of the party candidate to the cumulative vote count.
        general_election_party_performance.cumulative_vote_count += election.political_party_candidacy( political_party ).vote_count
        
        # We add the valid vote count in the election to the cumulative valid vote count.
        general_election_party_performance.cumulative_valid_vote_count += election.valid_vote_count
        
        # If the winning candidacy in the election represented the political party ...
        if political_party.won_election?( election )
        
          # ... we increment the constituency won count.
          general_election_party_performance.constituency_won_count += 1
        end
      end
      
      # We save the general election party performance record.
      general_election_party_performance.save!
    end
  end
end

# ## A task to regenerate parliamentary parties.
task :generate_2010_parliamentary_parties => :environment do
  puts "generating parliamentary parties"
  
  # This task populates:
  # * political_party.has_been_parliamentary_party
  
  # We find the general election.
  general_election = GeneralElection.find_by_polling_on( POLLING_ON )
  
  # We get all the political parties appearing in the general election party performance table for the 2010 general election whose constituency won count is greater than 0, being not already marked as parliamentary parties.
  # Noting that for the 2010 general election this returns zero parties, there being no winning parties who did not win between 2015 and 2019.
  # We keep this method for reuse in the 2024 general election import script in case a party wins an election who has not won an election between 2010 and 2019.
  political_parties = PoliticalParty.find_by_sql(
    "
      SELECT pp.*
      FROM political_parties pp, general_election_party_performances gepp
      WHERE pp.has_been_parliamentary_party IS FALSE
      AND pp.id = gepp.political_party_id
      AND gepp.general_election_id = #{general_election.id}
      AND gepp.constituency_won_count > 0
      ORDER BY pp.name;
    "
  )
  
  # For each political party not marked as parliamentary parties, having won an election in 2010 ...
  political_parties.each do |political_party|
    
    # ... we set the has been parliamentary party flag to true.
    political_party.has_been_parliamentary_party = true
    political_party.save!
  end
end

# ## A task to infill general election party performances.
task :infill_2010_general_election_party_performances => :environment do
  puts "infill general election party performances"
  
  # This task creates records for:
  # * general_election_party_performances
  
  # It populates:
  # * general_election_party_performance.general_election_id
  # * general_election_party_performance.political_party_id
  # * general_election_party_performance.constituency_contested_count
  # * general_election_party_performance.constituency_won_count
  # * general_election_party_performance.cumulative_vote_count
  # * general_election_party_performance.cumulative_valid_vote_count
  
  # We know that there are parties having certified candidacies in the 2015 - 2019 general elections who did not certify candidacies in the 2010 general election.
  # We also know that there are parties having certified candidacies in the 2010 general election who did not certify candidacies in the 2015 - 2019 general elections.
  # We want to list all general elections on the party pages, even where the constituency contest count is zero.
  # For that reason, we need to create nil contested general election party performance records for all political parties in all general elections having no exisiting general election party performance.
  
  # We get all the political parties.
  political_parties = PoliticalParty.all
  
  # We get all the populated, non-notional general elections.
  general_elections = GeneralElection.find_by_sql(
    "
      SELECT *
      FROM general_elections
      WHERE is_notional IS FALSE
      AND valid_vote_count != 0
    "
  )
  
  # For each populated, non-notional general election ...
  general_elections.each do |general_election|
    
    # ... for each political party ...
    political_parties.each do |political_party|
      
      # ... we attempt to find a general election party performance for that political party in that general election.
      general_election_party_performance = GeneralElectionPartyPerformance.find_by_sql(
        "
          SELECT *
          FROM general_election_party_performances
          WHERE political_party_id = #{political_party.id}
          AND general_election_id = #{general_election.id}
        "
      ).first
      
      # Unless we find a general election party performance for the political party in the general election ...
      unless general_election_party_performance
        
        # ... we create a new general election party performance for the political party in the general election...
        general_election_party_performance = GeneralElectionPartyPerformance.new
        general_election_party_performance.general_election = general_election
        general_election_party_performance.political_party = political_party
        
        # ... with nil values for constituency contested, constituency won, cumulative vote count and cumulative valid vote count.
        general_election_party_performance.constituency_contested_count = 0
        general_election_party_performance.constituency_won_count = 0
        general_election_party_performance.cumulative_vote_count = 0
        general_election_party_performance.cumulative_valid_vote_count = 0
        general_election_party_performance.save!
      end
    end
  end
end

# ## A task to generate country general election party performances.
task :generate_2010_country_general_election_party_performances => :environment do
  puts "generating country general election party performances"
  
  # This task creates records for:
  # * country_general_election_party_performances
  
  # It populates:
  # * country_general_election_party_performance.general_election_id
  # * country_general_election_party_performance.political_party_id
  # * country_general_election_party_performance.country_id
  # * country_general_election_party_performance.constituency_contested_count
  # * country_general_election_party_performance.constituency_won_count
  # * country_general_election_party_performance.cumulative_vote_count
  
  # We get the general election.
  general_election = GeneralElection.find_by_polling_on( POLLING_ON )
  
  # We get all the political parties.
  political_parties = PoliticalParty.all
  
  # We get all the countries.
  countries = Country.all
  
  # For each country ...
  countries.each do |country|
  
    # ... for each political party ...
    political_parties.each do |political_party|
        
      # ... for each election forming part of the general election in this country ...
      general_election.elections_in_country( country ).each do |election|
        
        # ... if a candidacy representing the political party is in the election ...
        if political_party.represented_in_election?( election )
          
          # ... we attempt to find the general election party performance for this party in this country.
          country_general_election_party_performance = CountryGeneralElectionPartyPerformance
            .all
            .where( "general_election_id = ?", general_election.id )
            .where( "political_party_id = ?", political_party.id )
            .where( "country_id = ?", country.id )
            .first
    
          # Unless we find the general election party performance for this party in this country ...
          unless country_general_election_party_performance
            
            # ... we create a general election party performance for this country with all counts set to zero.
            country_general_election_party_performance = CountryGeneralElectionPartyPerformance.new
            country_general_election_party_performance.general_election = general_election
            country_general_election_party_performance.political_party = political_party
            country_general_election_party_performance.country = country
            country_general_election_party_performance.constituency_contested_count = 0
            country_general_election_party_performance.constituency_won_count = 0
            country_general_election_party_performance.cumulative_vote_count = 0
          end
          
          # We increment the constituency contested count ...
          country_general_election_party_performance.constituency_contested_count += 1
          
          # ... and add the vote count of the party candidate to the cumulative vote count.
          country_general_election_party_performance.cumulative_vote_count += election.political_party_candidacy( political_party ).vote_count
        
          # If the winning candidacy in the election represented the political party ...
          if political_party.won_election?( election )
        
            # ... we increment the constituency won count,
            country_general_election_party_performance.constituency_won_count += 1
          end
          
          # We save the country general election party performance record.
          country_general_election_party_performance.save!
        end
      end
    end
  end
end

# ## A task to generate English region general election party performances.
task :generate_2010_english_region_general_election_party_performances => :environment do
  puts "generating english region general election party performances"
  
  # This task creates records for:
  # * english_region_general_election_party_performance
  
  # It populates:
  # * english_region_general_election_party_performance.general_election_id
  # * english_region_general_election_party_performance.political_party_id
  # * english_region_general_election_party_performance.english_region_id
  # * english_region_general_election_party_performance.constituency_contested_count
  # * english_region_general_election_party_performance.constituency_won_count
  # * english_region_general_election_party_performance.cumulative_vote_count
  
  # We get the general election.
  general_election = GeneralElection.find_by_polling_on( POLLING_ON )
  
  # We get all the political parties.
  political_parties = PoliticalParty.all
  
  # We get all the english regions.
  english_regions = EnglishRegion.all
  
  # For each english region ...
  english_regions.each do |english_region|
  
    # ... for each political party ...
    political_parties.each do |political_party|
        
      # ... for each election forming part of the general election in this english region ...
      general_election.elections_in_english_region( english_region ).each do |election|
        
        # ... if a candidacy representing the political party is in the election ...
        if political_party.represented_in_election?( election )
          
          # ... we attempt to find the general election party performance for this party in this english region.
          english_region_general_election_party_performance = EnglishRegionGeneralElectionPartyPerformance
            .all
            .where( "general_election_id = ?", general_election.id )
            .where( "political_party_id = ?", political_party.id )
            .where( "english_region_id = ?", english_region.id )
            .first
    
          # Unless we find the general election party performance for this party in this english region ...
          unless english_region_general_election_party_performance
            
            # ... we create a general election party performance for this english region with all counts set to zero.
            english_region_general_election_party_performance = EnglishRegionGeneralElectionPartyPerformance.new
            english_region_general_election_party_performance.general_election = general_election
            english_region_general_election_party_performance.political_party = political_party
            english_region_general_election_party_performance.english_region = english_region
            english_region_general_election_party_performance.constituency_contested_count = 0
            english_region_general_election_party_performance.constituency_won_count = 0
            english_region_general_election_party_performance.cumulative_vote_count = 0
          end
          
          # We increment the constituency contested count ...
          english_region_general_election_party_performance.constituency_contested_count += 1
          
          # ... and add the vote count of the party candidate to the cumulative vote count.
          english_region_general_election_party_performance.cumulative_vote_count += election.political_party_candidacy( political_party ).vote_count
        
          # If the winning candidacy in the election represented the political party ...
          if political_party.won_election?( election )
        
            # ... we increment the constituency won count,
            english_region_general_election_party_performance.constituency_won_count += 1
          end
          
          # We save the english region general election party performance record.
          english_region_general_election_party_performance.save!
        end
      end
    end
  end
end

# ## A task to generate boundary set general election party performances.
task :generate_2010_boundary_set_general_election_party_performances => :environment do
  puts "generating boundary set general election party performances"
  
  # This task creates records for:
  # * boundary_set_general_election_party_performances
  
  # It populates:
  # * boundary_set_general_election_party_performance.general_election_id
  # * boundary_set_general_election_party_performance.political_party_id
  # * boundary_set_general_election_party_performance.boundary_set_id
  # * boundary_set_general_election_party_performance.constituency_contested_count
  # * boundary_set_general_election_party_performance.constituency_won_count
  # * boundary_set_general_election_party_performance.cumulative_vote_count
  
  # We get the general election.
  general_election = GeneralElection.find_by_polling_on ( POLLING_ON )
  
  # Whilst general election party performances, country general election party performances and english region general election party performances tables contain records for all parties - regardless of whether they've ever won an election - the boundary set general election party performances table only contains parties who have won an election.
  # For that reason, we get all the political parties having won a parliamentary election.
  political_parties = PoliticalParty.all.where( 'has_been_parliamentary_party IS TRUE' )
  
  # We get all the boundary sets.
  boundary_sets = BoundarySet.all
  
  # For each boundary set ...
  boundary_sets.each do |boundary_set|
  
    # ... for each political party ...
    political_parties.each do |political_party|
        
      # ... for each election forming part of the general election in this boundary set ...
      general_election.elections_in_boundary_set( boundary_set ).each do |election|
          
        # ... if a candidacy representing the political party is in the election ...
        if political_party.represented_in_election?( election )
            
          # ... we attempt to find the general election party performance for this party in this boundary set.
          boundary_set_general_election_party_performance = BoundarySetGeneralElectionPartyPerformance
            .all
            .where( "general_election_id = ?", general_election.id )
            .where( "political_party_id = ?", political_party.id )
            .where( "boundary_set_id = ?", boundary_set.id )
            .first
      
          # Unless we find the general election party performance for this party in this boundary set ...
          unless boundary_set_general_election_party_performance
              
            # ... we create a general election party performance for this boundary set with all counts set to zero.
            boundary_set_general_election_party_performance = BoundarySetGeneralElectionPartyPerformance.new
            boundary_set_general_election_party_performance.general_election = general_election
            boundary_set_general_election_party_performance.political_party = political_party
            boundary_set_general_election_party_performance.boundary_set = boundary_set
            boundary_set_general_election_party_performance.constituency_contested_count = 0
            boundary_set_general_election_party_performance.constituency_won_count = 0
            boundary_set_general_election_party_performance.cumulative_vote_count = 0
          end
            
          # We increment the constituency contested count ...
          boundary_set_general_election_party_performance.constituency_contested_count += 1
          
          # ... and add the vote count of the party candidate to the cumulative vote count.
          boundary_set_general_election_party_performance.cumulative_vote_count += election.political_party_candidacy( political_party ).vote_count
        
          # If the winning candidacy in the election represented the political party ...
          if political_party.won_election?( election )
        
            # ... we increment the constituency won count,
            boundary_set_general_election_party_performance.constituency_won_count += 1
          end
            
          # We save the general election party performance record.
          boundary_set_general_election_party_performance.save!
        end
      end
    end
  end
end

# ## A task to infill missing boundary set general election party performances.
task :infill_2010_missing_boundary_set_general_election_party_performances => :environment do
  puts "infilling missing boundary_set_general election party performances"
  
  # We know that some political parties have stood candidates in some general elections in a boundary set but not in others.
  # This makes it difficult to render boundary set level party performance tables.
  # For any boundary set in a general election with no candidates from a given political party, where that political party has stood candidates in other general elections in that boundary set, we create a boundary set general election party performance record having no contested, won or vote counts.
  # We get all boundary sets.
  boundary_sets = BoundarySet.all
  
  # For each boundary set ...
  boundary_sets.each do |boundary_set|
    
    # ... we get all general elections across the boundary set.
    general_elections = boundary_set.general_elections
    
    # We get all the political parties having stood a - winning - candidate in that boundary set.
    # Noting that the boundary set general election party performances table is only populated with political parties having won at least one election.
    political_parties = PoliticalParty.find_by_sql(
      "
        SELECT pp.*
        FROM political_parties pp, boundary_set_general_election_party_performances bsgepp
        WHERE pp.id = bsgepp.political_party_id
        AND bsgepp.boundary_set_id = #{boundary_set.id}
        GROUP BY pp.id
      "
    )
    
    # Unless there are no political_parties having stood a candidate in this boundary set ...
    unless political_parties.empty?
      
      # ... for each political party ...
      political_parties.each do |political_party|
        
        # ... for each general election ...
        general_elections.each do |general_election|
          
          # ... we attempt to find a boundary set general election party performance for this party in this general election in this boundary set.
          boundary_set_general_election_party_performance = BoundarySetGeneralElectionPartyPerformance.find_by_sql(
            "
              SELECT bsgepp.*
              FROM boundary_set_general_election_party_performances bsgepp
              WHERE bsgepp.political_party_id = #{political_party.id}
              AND bsgepp.general_election_id = #{general_election.id}
              AND bsgepp.boundary_set_id = #{boundary_set.id}
            "
          ).first
          
          # Unless we find a boundary set general election party performance for this party in this general election in this boundary set ...
          unless boundary_set_general_election_party_performance
            
            # ... we create a new boundary set general election party performance record.
            boundary_set_general_election_party_performance = BoundarySetGeneralElectionPartyPerformance.new
            boundary_set_general_election_party_performance.constituency_contested_count = 0
            boundary_set_general_election_party_performance.constituency_won_count = 0
            boundary_set_general_election_party_performance.cumulative_vote_count = 0
            boundary_set_general_election_party_performance.general_election = general_election
            boundary_set_general_election_party_performance.political_party = political_party
            boundary_set_general_election_party_performance.boundary_set = boundary_set
            boundary_set_general_election_party_performance.save!
          end
        end
      end
    end
  end
end

# ## A task to report the end time.
task :report_end_time => :environment do
  puts "import ended at #{Time.now}"
end