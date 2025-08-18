# ## A task to import maiden speeches.

task :import_maiden_speeches => :environment do
  puts "importing maiden speeches"
  
  # We set the location of the maiden speech CSV.
  maiden_speech_file = 'db/data/maiden-speeches.csv'
  
  # For each maiden speech ...
  CSV.foreach( maiden_speech_file).with_index do |row, index|
    next if index == 0 # Skip the first row
    
    # We store the variables we need to create the maiden speech.
    made_on = row[4].to_date
    parliament_number = row[0]
    session_number = row[1]
    member_mnis_id = row[8] if row[8] != '[x]'
    constituency_mnis_id =  row[11] if row[11] != '[x]'
    hansard_reference = row[12]
    hansard_url = row[13]
    
    # If the maiden speech has a member MNIS ID ...
    if member_mnis_id
      
      # ... we attempt to find the Member.
      member = Member.find_by_mnis_id( member_mnis_id )
      
      # If we find the Member ...
      if member
      
        # ... we find the Parliament period.
        parliament_period = ParliamentPeriod.find_by_number( parliament_number )
        
        # If the maiden speech PFF has a constituency MNIS identifier ...
        if constituency_mnis_id
        
          # We find the constituency group.
          constituency_group = ConstituencyGroup.find_by_sql(
            "
              SELECT cg.*
              FROM constituency_groups cg, constituency_areas ca
              WHERE cg.constituency_area_id = ca.id
              AND ca.mnis_id = #{constituency_mnis_id}
            "
          ).first
          
          # If we find the constituency group ...
          if constituency_group

            # We attempt to find a maiden speech by this Member.
            maiden_speech = MaidenSpeech.find_by_member_id( member.id )
  
            # Unless we find a maiden speech by this member ...
            unless maiden_speech
  
              # ... we create a new maiden speech.
              maiden_speech = MaidenSpeech.new
              maiden_speech.member = member
              puts " - creating maiden speech record for #{member.given_name} #{member.family_name}"
            end
  
            # We update the details of the maiden speech.
            maiden_speech.made_on = made_on
            maiden_speech.session_number = session_number
            maiden_speech.hansard_reference = hansard_reference
            maiden_speech.hansard_url = hansard_url
            maiden_speech.constituency_group = constituency_group
            maiden_speech.parliament_period = parliament_period
            maiden_speech.save!
          end
        end
      end
    end
  end
end