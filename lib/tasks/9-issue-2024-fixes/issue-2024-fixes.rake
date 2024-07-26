require 'csv'

task :issue_2024_fixes => [
  :report_start_time,
  :update_election_data_2024,
  :update_candidacy_data_2024,
  # Given a candidacy vote count may have changed, it's possible result positions may also have changed.
  # We use the populate_2024_result_positions task from the import_2024_general_election file to regenerate result positions.
  # This resets:
  # * candidacies.result_position
  :populate_2024_result_positions,
  
  # Given election valid vote counts, invalid vote counts and electorate may have changed, it's possible aggregate numbers for the general election as a whole may also have changed.
  # We use the generate_2024_cumulative_counts task from the import_2024_general_election file to regenerate these.
  # This resets:
  # * general_election.valid_vote_count
  # * general_election.invalid_vote_count
  # * general_election.electorate_population_count
  :generate_2024_cumulative_counts,
  :clear_2024_aggregate_tables,
  
  # Having cleared out the aggregate tables for the 2024 general election, we need to repopulate them.
  # We call three taks from the import_2024_general_election file to do this.
  :generate_2024_general_election_party_performances,
  :generate_2024_country_general_election_party_performances,
  :generate_2024_english_region_general_election_party_performances,
  :report_end_time
]

# ## A task to update election records for the 2024 general election.
task :update_election_data_2024 => :environment do
  puts "updating election records for the 2024 general election"
  
  # We update results for the 2024 general election.
  update_election_data_for_general_election( '2024-07-04', 59 )
end

# ## A task to update candidacy records for the 2024 general election.
task :update_candidacy_data_2024 => :environment do
  puts "updating candidacy records for the 2024 general election"
  
  # We update results for the 2024 general election.
  update_candidacy_data_for_general_election( '2024-07-04', 59 )
end

# ## A task to clear aggregate tables for the 2024 general election.
# This task clear 2024 records from:
# * general_election_party_performances
# * country_general_election_party_performances
# * english_region_general_election_party_performances
# The boundary_set_general_election_party_performances table only includes parties who have won an election. Given we do not expect winning candidacies to change, we don't need to clear and recreate that table.
task :clear_2024_aggregate_tables => :environment do
  puts "clearing aggregate tables for the 2024 general election"
  
  # We find the general election.
  general_election = GeneralElection.find_by_sql(
    "
      SELECT *
      FROM general_elections
      WHERE polling_on = '#{POLLING_ON_2024}'
      AND is_notional IS FALSE
    "
  ).first
  
  # We find all general election party performance records for the 2024 general election.
  general_election_party_performances = GeneralElectionPartyPerformance.where( "general_election_id = ?", general_election.id )
  
  # For each general election party performance record for the 2024 general election ...
  general_election_party_performances.each do |general_election_party_performance|
    
    # ... we destroy it.
    general_election_party_performance.destroy!
  end
  
  # We find all country general election party performance records for the 2024 general election.
  country_general_election_party_performances = CountryGeneralElectionPartyPerformance.where( "general_election_id = ?", general_election.id )
  
  # For each country general election party performance record for the 2024 general election ...
  country_general_election_party_performances.each do |country_general_election_party_performance|
    
    # ... we destroy it.
    country_general_election_party_performance.destroy!
  end
  
  # We find all english region general election party performance records for the 2024 general election.
  english_region_general_election_party_performances = EnglishRegionGeneralElectionPartyPerformance.where( "general_election_id = ?", general_election.id )
  
  # For each country general election party performance record for the 2024 general election ...
  english_region_general_election_party_performances.each do |english_region_general_election_party_performance|
    
    # ... we destroy it.
    english_region_general_election_party_performance.destroy!
  end
end



# We update election level records.
def update_election_data_for_general_election( date, parliament_number )
  
  # Updates election level data where it differs in the spreadsheet and database:
  # * electorates.population_count
  # * elections.valid_vote_count
  # * elections.invalid_vote_count
  # * elections.majority
  
  # We find the general election.
  general_election = GeneralElection.find_by_sql(
    "
      SELECT *
      FROM general_elections
      WHERE polling_on = '#{date}'
      AND is_notional IS FALSE
    "
  ).first
  
  # We set the path to the constituencies CSV file.
  constituencies_file = "db/data/results-by-parliament/#{PARLIAMENT_NUMBER_2024}/general-election/constituencies.csv"

  # For each row in the results sheet ...
  CSV.foreach( constituencies_file ).with_index do |row, index|
    
    # ... we skip the first row.
    next if index == 0
    
    # We store the data we need to find the election.
    constituency_area_geographic_code = ActiveRecord::Base.connection.quote( row[0] )
    
    # We store the data we may want to capture in the database if it differs from the data recorded.
    election_valid_vote_count = row[15].strip if row[15]
    election_invalid_vote_count = row[16].strip if row[16]
    election_majority = row[17].strip if row[17]
    electorate_count = row[14].strip if row[14]
    
    # We find the election.
    election = Election.find_by_sql(
      "
        SELECT e.*
        FROM elections e, constituency_groups cg, constituency_areas ca
        WHERE e.general_election_id = #{general_election.id}
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.geographic_code = #{constituency_area_geographic_code}
      "
    ).first
    
    # We set a flag to say the election record has not been changed, so we don't save it if we don't need to.
    election_record_changed = false
    
    # If the spreadsheet has a different value to the database for valid vote counts ...
    if election.valid_vote_count != election_valid_vote_count.to_i
      
      # ... we update the database value.
      election.valid_vote_count = election_valid_vote_count
      
      # And record that the election record has changed.
      election_record_changed = true
    end
    
    # If the spreadsheet has a different value to the database for invalid vote counts ...
    if election.invalid_vote_count != election_invalid_vote_count.to_i
      
      # ... we update the database value.
      election.invalid_vote_count = election_invalid_vote_count
      
      # And record that the election record has changed.
      election_record_changed = true
    end
    
    # If the spreadsheet has a different value to the database for majority ...
    if election.majority != election_majority.to_i
      
      # ... we update the database value.
      election.majority = election_majority
      
      # And record that the election record has changed.
      election_record_changed = true
    end
    
    # We save the election record, if we've flagged it as changed.
    election.save! if election_record_changed
    
    # We find the electorate associated with the election.
    electorate = election.electorate
    
    # If the spreadsheet has a different value to the database for electorate population count ...
    if electorate.population_count != electorate_count.to_i
      
      # ... we update the database value ...
      electorate.population_count = electorate_count
      
      # ... and save the electorate record.
      electorate.save!
    end
  end
end

# We update candidacy level records.
def update_candidacy_data_for_general_election( date, parliament_number )
  
  # Updates candidacy level data where it differs in the spreadsheet and database:
  # * candidacies.vote_count
  # * candidacies.vote_share
  # * candidacies.vote_change
  # * candidacies.candidate_gender_id
  
  # We find the general election.
  general_election = GeneralElection.find_by_sql(
    "
      SELECT *
      FROM general_elections
      WHERE polling_on = '#{date}'
      AND is_notional IS FALSE
    "
  ).first
  
  # We set the path to the candidacies CSV file.
  candidacies_file = "db/data/results-by-parliament/#{PARLIAMENT_NUMBER_2024}/general-election/candidacies.csv"

  # For each row in the results sheet ...
  CSV.foreach( candidacies_file ).with_index do |row, index|
    
    # ... we skip the first row.
    next if index == 0
    
    # We store the data we need to find the candidacy.
    candidacy_democracy_club_person_identifier = row[21].strip if row[21]
    
    # We store the data we may want to capture in the database if it differs from the data recorded.
    candidacy_vote_count = row[18].strip if row[18]
    candidacy_vote_share = row[19].strip if row[19]
    candidacy_vote_change = row[20].strip if row[20]
    candidacy_candidate_gender = row[14].strip if row[14]
    
    # We find the candidacy and the gender of the candidate.
    candidacy = Candidacy.find_by_sql(
      "
        SELECT cand.*, g.gender
        FROM candidacies cand, elections e, genders g
        WHERE cand.election_id = e.id
        AND e.general_election_id = #{general_election.id}
        AND cand.democracy_club_person_identifier = #{candidacy_democracy_club_person_identifier}
        AND cand.candidate_gender_id = g.id
      "
    ).first
    
    # We set a flag to say the candidacy record has not been changed, so we don't save it if we don't need to.
    candidacy_record_changed = false
    
    # If the spreadsheet has a different value to the database for vote count ...
    if candidacy.vote_count != candidacy_vote_count.to_i
      
      # ... we update the database value.
      candidacy.vote_count = candidacy_vote_count
      
      # And record that the candidacy record has changed.
      candidacy_record_changed = true
    end
    
    # If the spreadsheet has a different value to the database for vote share ...
    if candidacy.vote_share != candidacy_vote_share.to_f
      
      # ... we update the database value.
      candidacy.vote_share = candidacy_vote_share
      
      # And record that the candidacy record has changed.
      candidacy_record_changed = true
    end
    
    # If the CSV file has a non-null vote change ...
    if candidacy_vote_change
      
      # ... if the database has a none null vote change ...
      if candidacy_vote_change
        
        # ... if the CSV file has a different value for the vote change to the database ...
        if candidacy.vote_change != candidacy_vote_change.to_f
          
          # ... we update the database value.
          candidacy.vote_change = candidacy_vote_change
          
          # And record that the candidacy record has changed.
          candidacy_record_changed = true
        end
      
      # Otherwise, if the database has a null vote change ...
      else
          
        # ... we update the database value.
        candidacy.vote_change = candidacy_vote_change
          
        # And record that the candidacy record has changed.
        candidacy_record_changed = true
      end
    
    # Otherwise, if the CVS has a null vote change ...
    else
      
      # ... if the database has a non-null change.
      if candidacy_vote_change
        
        # ... we update the database value to null.
        candidacy.vote_change = nil
          
        # And record that the candidacy record has changed.
        candidacy_record_changed = true
      end
    end
    
    # If the candidate gender recorded in the CSV file does not match the candidate gender recorded in the database ...
    if candidacy.gender != candidacy_candidate_gender
      
      # ... we find the gender as recorded in the CSV file ...
      gender = Gender.find_by_gender( candidacy_candidate_gender )
      
      # ... assign the new gender to the candidacy in the database ...
      candidacy.candidate_gender = gender
          
      # ... and record that the candidacy record has changed.
      candidacy_record_changed = true
    end
    
    # We save the candidacy record, if we've flagged it as changed.
    candidacy.save! if candidacy_record_changed
  end
end