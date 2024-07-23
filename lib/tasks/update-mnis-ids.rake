require 'csv'

task :update_mnis_ids => [
  :report_start_time,
  :update_mnis_ids_for_previous_elections,
  :report_end_time
]

# ## A task to update MNIS IDs for unsuccessful candidacies in previous elections.
task :update_mnis_ids_for_previous_elections => :environment do
  puts "updating MNIS IDs for unsuccessful candidacies in previous elections"
  
  # We update results for the 2010 general election.
  update_mins_ids_for_general_election( '2010-05-06', 55 )
  
  # We update results for the 2015 general election.
  update_mins_ids_for_general_election( '2015-05-07', 56 )
  
  # We update results for the 2017 general election.
  update_mins_ids_for_general_election( '2017-06-08', 57 )
  
  # We update results for the 2019 general election.
  update_mins_ids_for_general_election( '2019-12-12', 58 )
end


# We update MNIS IDs for unsuccessful candidacies in a given general election to a given Parliament.
def update_mins_ids_for_general_election( date, parliament_number )
  
  # We find the general election.
  general_election = GeneralElection.find_by_sql(
    "
      SELECT *
      FROM general_elections
      WHERE polling_on = '#{date}'
      AND is_notional IS FALSE
    "
  ).first
  
  # For each row in the results sheet ...
  CSV.foreach( "db/data/results-by-parliament/#{parliament_number}/general-election/candidacies.csv" ) do |row|
    
    # ... we store the values from the spreadsheet.
    candidacy_constituency_area_geographic_code = row[0].strip if row[0]
    candidacy_candidate_given_name = ActiveRecord::Base.connection.quote( row[12].strip ) if row[12]
    candidacy_candidate_family_name = ActiveRecord::Base.connection.quote( row[13].strip ) if row[13]
    candidacy_candidate_mnis_member_id = row[17].strip if row[17]
    
    # If the candidacy has a MNIS member ID ...
    if candidacy_candidate_mnis_member_id
      
      # ... we attempt to find the candidacy.
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
      
      # If the candidacy it has no member ID ....
      unless candidacy.member_id
        
        # ... we attempt to find the Member.
        member = Member.find_by_mnis_id( candidacy_candidate_mnis_member_id )
        
        # Unless we find the Member ...
        unless member
          
          # ... we create it.
          member = Member.new
          member.given_name = candidacy_candidate_given_name
          member.family_name = candidacy_candidate_family_name
          member.mnis_id = candidacy_candidate_mnis_member_id
          member.save!
        end
        
        # We associate the candidacy with the Member.
        candidacy.member = member
        candidacy.save!
      end
    end
  end
end