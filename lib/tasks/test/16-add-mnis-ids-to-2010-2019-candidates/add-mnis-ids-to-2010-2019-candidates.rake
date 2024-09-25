# ## A task to add mnis ids to 2010 - 2019 candidates.
task :add_mnis_ids_to_2010_to_2019_candidates => :environment do
  puts "adding mnis ids to 2010 - 2019 candidates"
  
  # We add mnis ids for the 2010-05-06 general election.
  parliament_number = 55
  polling_on = '2010-05-06'
  add_missing_mnis_ids( parliament_number, polling_on )
  
  # We add mnis ids for the 2015-05-07 general election.
  parliament_number = 56
  polling_on = '2015-05-07'
  add_missing_mnis_ids( parliament_number, polling_on )
  
  # We add mnis ids for the 2017-06-08 general election.
  parliament_number = 57
  polling_on = '2017-06-08'
  add_missing_mnis_ids( parliament_number, polling_on )
  
  # We add mnis ids for the 2019-12-12 general election.
  parliament_number = 58
  polling_on = '2019-12-12'
  add_missing_mnis_ids( parliament_number, polling_on )
end
  
def add_missing_mnis_ids( parliament_number, polling_on )

  # We find the parliament period.
  parliament_period = ParliamentPeriod.find_by_number( parliament_number )

  # We find the general election.
  general_election = GeneralElection.find_by_polling_on( polling_on )
  
  # For each row in the results sheet ...
  CSV.foreach( "db/data/results-by-parliament/#{parliament_number}/general-election/candidacies.csv" ) do |row|
    
    # ... we store the values from the spreadsheet.
    candidacy_constituency_area_geographic_code = row[0].strip if row[0]
    candidacy_candidate_given_name = ActiveRecord::Base.connection.quote( row[12].strip )
    candidacy_candidate_family_name = ActiveRecord::Base.connection.quote( row[13].strip )
    candidacy_candidate_mnis_member_id = row[17].strip.to_i if row[17]
    
    # If the candidate mnis id is not blank ...
    unless candidacy_candidate_mnis_member_id.blank?
    
      # We find the candidacy ...
      candidacy = Candidacy.find_by_sql(
        "
          SELECT cand.*
          FROM candidacies cand, elections e, constituency_groups cg, constituency_areas ca
          WHERE cand.election_id = e.id
          AND e.general_election_id = #{general_election.id}
          AND e.constituency_group_id = cg.id
          AND cg.constituency_area_id = ca.id
          AND ca.geographic_code = '#{candidacy_constituency_area_geographic_code}'
          AND cand.candidate_given_name = #{candidacy_candidate_given_name}
          AND cand.candidate_family_name = #{candidacy_candidate_family_name}
        "
      ).first
      
      # Unless the candidacy has a member id ...
      unless candidacy.member_id
      
        # ... we find the member ...
        member = Member.find_by_mnis_id( candidacy_candidate_mnis_member_id )
        
        # ... and associate the member with the candidacy.
        candidacy.member = member
        candidacy.save!
      end
    end
  end
end
  
  
  
  
  