# We set the Parliament number.
# This gets picked up automatically from update-2024.rake - same constant name
# PARLIAMENT_NUMBER_2024 = 59


# ## A task to reassign 2024 parties.
task :reassign_2024_parties => :environment do
  puts "reassigning_2024_parties"
  # We find the general election this election forms part of.
  general_election = GeneralElection.find_by_polling_on( POLLING_ON_2024 )

  candidacies_file = "db/data/results-by-parliament/#{PARLIAMENT_NUMBER_2024}/general-election/candidacies.csv"

  # For each row in the results sheet ...
  CSV.foreach(candidacies_file).with_index do |row, index|
    next if index == 0 # Skip the first row

    # ... we store the values from the spreadsheet.
    candidacy_main_political_party_name = row[7].strip if row[7]
    candidacy_main_political_party_abbreviation = row[8].strip if row[8]
    candidacy_main_political_party_electoral_commission_id = row[9].strip if row[9]
    candidacy_main_political_party_mnis_id = row[10].strip if row[10]
    candidacy_adjunct_political_party_electoral_commission_id = row[11].strip if row[11]
    candidacy_democracy_club_person_identifier = row[21].strip if row[21]
    
    # If the candidacy is potentially updateable ...
    if candidacy_is_potentially_updateable?( candidacy_main_political_party_name, candidacy_main_political_party_abbreviation )
    
      # ... we find the candidacy.
      candidacy = Candidacy.find_by_democracy_club_person_identifier( candidacy_democracy_club_person_identifier )
      
      # We find the political party the candidacy was certified by.
      political_party = PoliticalParty.find_by_sql(
        "
          SELECT pp.*
          FROM political_parties pp, certifications cert
          WHERE cert.political_party_id = pp.id
          AND cert.candidacy_id = #{candidacy.id}
          AND cert.adjunct_to_certification_id IS NULL"
      ).first
      
      # If the political party name in the database does not match the political party name in the spreadsheet ...
      if political_party.name != candidacy_main_political_party_name
        puts "*****"
        puts "Party name in database: #{political_party.name}"
        puts "MNIS ID in database: #{political_party.mnis_id}"
        puts "Party name in spreadsheet: #{candidacy_main_political_party_name}"
        puts "MNIS ID in spreadsheet: #{candidacy_main_political_party_mnis_id}"
      end
    end
  end
end

def candidacy_is_potentially_updateable?( candidacy_main_political_party_name, candidacy_main_political_party_abbreviation )

  # We state that the candidacy is potentially updateable.
  candidacy_is_potentially_updateable = true
  
  # We say the candidacy is not potentially updateable if the main party name is 'Speaker'.
  candidacy_is_potentially_updateable = false if candidacy_main_political_party_name == 'Speaker'
  
  # We say the candidacy is not potentially updateable if the main party name is 'Independent'.
  candidacy_is_potentially_updateable = false if candidacy_main_political_party_name == 'Independent'
  
  # We want to avoid any Labour / Co-op tangles so ...
  # ... we say the candidacy is not potentially updateable if the main party name is 'Labour and Co-operative'.
  candidacy_is_potentially_updateable = false if candidacy_main_political_party_name == 'Labour and Co-operative'
  
  # We've made changes across the three Green Parties so ...
  # ... we say the candidacy is not potentially updateable if the main party abbreviation is 'Green'.
  candidacy_is_potentially_updateable = false if candidacy_main_political_party_abbreviation == 'Green'
  
  # We also ignore Sinn Fein.
  candidacy_is_potentially_updateable = false if candidacy_main_political_party_name == 'Sinn Fein'
  
  
  candidacy_is_potentially_updateable
end