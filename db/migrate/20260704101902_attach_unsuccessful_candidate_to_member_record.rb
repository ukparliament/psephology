class AttachUnsuccessfulCandidateToMemberRecord < ActiveRecord::Migration[8.1]
  def change
  
    # We find the unsuccessful candidacy.
    candidacy = Candidacy.find( 14368 )
    
    # We set its Member Id.
    candidacy.member_id = 1407
    candidacy.save!
  end
end
