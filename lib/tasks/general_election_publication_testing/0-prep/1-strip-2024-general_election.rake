task :strip_2024_general_election => :environment do

  # We find the 2024 general election.
  general_election = GeneralElection.find( 6)
  
  # For each election in the general election ...
  general_election.elections.each do |election|
  
    # ... for each candidacy in the election ...
    election.candidacies.each do |candidacy|
    
      # ...for each adjunct certification of the candidacy ...
      candidacy.adjunct_certifications.each do |adjunct_certification|
      
        # ... we destroy the certification.
        adjunct_certification.destroy!
      end
    
      # ...for each main certification of the candidacy ...
      candidacy.main_certifications.each do |main_certification|
      
        # ... we destroy the certification.
        main_certification.destroy!
      end
      
      # We destroy the candidacy.
      candidacy.destroy!
    end
    
    # We destroy the election.
    election.destroy!
  end
  
  # We set the general election count fields to null
  general_election.valid_vote_count = nil
  general_election.invalid_vote_count = nil
  general_election.electorate_population_count = nil
  
  # We set the general election published state to unpublished.
  general_election.general_election_publication_state_id = 1
  
  # We save the general election.
  general_election.save!
end