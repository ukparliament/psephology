# ## A task to import political party registrations.
task :import_political_party_registrations => :environment do
  puts "importing political party registrations"
  
  # We point to the political party registrations CSV file.
  registrations_file = "db/data/political-party-registrations.csv"

  # For each row in the political party registrations file ...
  CSV.foreach( registrations_file ).with_index do |row, index|
    
    # ... we skip the header row.
    next if index == 0
    
    # We store the values from the spreadsheet.
    political_party_mnis_id = row[0]
    political_party_name = row[1].strip if row[1]
    political_party_electoral_commission_id = row[2].strip if row[2]
    registration_jurisdiction = row[3].strip if row[3]
    registration_start_on = row[4].to_date if row[4]
    registration_end_on = row[5].to_date if row[5]
    political_party_name_last_updated_on = row[6].to_date if row[6]
    
    # If the political party electoral commission id is blank (denoted by a hyphen or a blank) ...
    if political_party_electoral_commission_id == '-' || political_party_electoral_commission_id.blank?
      
      # ... we ignore.
      
    # Otherwise, if the political party electoral commission id is not blank ...
    else
      
      # We find the country.
      country = Country.find_by_name( registration_jurisdiction )
      
      # We attempt to find the political party.
      political_party = PoliticalParty.find_by_mnis_id( political_party_mnis_id )
      
      # If we fail to find the political party ...
      unless political_party
        
        # ... we report it couldn't be found.
        puts "unable to find political party: #{political_party_name}"
        
      # Otherwise, if we find the political party ..
      else
        
        # ... we attempt to find a political party registration for this political party in this country with this electoral commission id and start date.
        political_party_registration = PoliticalPartyRegistration.find_by_sql(
          "
            SELECT ppr.*
            FROM political_party_registrations ppr
            WHERE ppr.political_party_id = #{political_party.id}
            AND ppr.country_id = #{country.id}
            AND ppr.electoral_commission_id = '#{political_party_electoral_commission_id}'
            AND ppr.start_on = '#{registration_start_on}'
          "
        ).first
        
        # Unless we find the political party registration ...
        unless political_party_registration
          
          # ... we create a new political party registration.
          political_party_registration = PoliticalPartyRegistration.new
          political_party_registration.electoral_commission_id = political_party_electoral_commission_id
          political_party_registration.start_on = registration_start_on
          political_party_registration.political_party = political_party
          political_party_registration.country = country
        end
        
        # We assign the end date and the name last updated on dates.
        political_party_registration.end_on = registration_end_on
        political_party_registration.political_party_name_last_updated_on = political_party_name_last_updated_on
        
        # We save the political party registration.
        political_party_registration.save!
      end
    end
  end
end