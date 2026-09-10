class FixIncorrectMemberIdsIn2019GeneralElection < ActiveRecord::Migration[8.1]
  def change
  
    ## Beaconsfield
    
    # We find the Adam Clearly candidacy ...
    candidacy = Candidacy.find( 7429 )
    
    # ... and remove its Member ID.
    candidacy.member_id = nil
    candidacy.save!
    
    # We find the Dominic Grieve candidacy ...
    candidacy = Candidacy.find( 7430 )
    
    # ... and add its Member ID.
    candidacy.member_id = 38
    candidacy.save!
    
    
    # ## Bury South
    
    # We find the Michael Boyle candidacy ...
    candidacy = Candidacy.find( 7788 )
    
    # ... and remove its Member ID.
    candidacy.member_id = nil
    candidacy.save!
    
    # We find the Ivan Lewis candidacy ...
    candidacy = Candidacy.find( 7789 )
    
    # ... and add its Member ID.
    candidacy.member_id = 130
    candidacy.save!
  end
end
