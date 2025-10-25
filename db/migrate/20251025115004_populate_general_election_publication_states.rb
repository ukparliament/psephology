class PopulateGeneralElectionPublicationStates < ActiveRecord::Migration[8.0]
  def up
    GeneralElectionPublicationState.create(label: "Pre-election candidates", state: 1)
    GeneralElectionPublicationState.create(label: "Post-election winners", state: 2)
    GeneralElectionPublicationState.create(label: "Post-election votes", state: 3)
  end

  def down
    GeneralElectionPublicationState.delete_all
  end
end
