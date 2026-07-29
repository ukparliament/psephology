class FixDuplicateCandidacies < ActiveRecord::Migration[8.1]
  def change
  
    # We find the CPA certification for Peter Richardson ...
    certification = Certification.find( 21508 )
    
    # ... and destroy it.
    certification.destroy!
  
    # We find the UKIP certification for Laura Corke ...
    certification = Certification.find( 21507 )
    
    # ... and destroy it.
    certification.destroy!
  end
end
