class PopulateForeignKeyFromGeneralElectionsToGeneralElectionPublicationState < ActiveRecord::Migration[8.0]
  def change
    GeneralElection.all.each do |ge|
      ge.general_election_publication_state_id = 3
      ge.save!
    end
  end
end
