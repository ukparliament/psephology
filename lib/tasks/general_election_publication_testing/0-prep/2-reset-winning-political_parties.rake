task :reset_winning_political_parties => :environment do

  # We get all the political parties.
  political_parties = PoliticalParty.all.order( 'name' )
  
  # For each political party ...
  political_parties.each do |political_party|
  
    # ... if the political party has won no elections ...
    if political_party.winning_candidacies.size == 0
    
      # ... we set the has been parliamentary party boolean to false.
      political_party.has_been_parliamentary_party = false
      
    # Otherwise, if the political party has won one or more elections ...
    else
    
      # ... we set the has been parliamentary party boolean to true.
      political_party.has_been_parliamentary_party = true
    end
    
    # We save the political party.
    political_party.save!
  end
end






