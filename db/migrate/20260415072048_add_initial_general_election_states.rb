class AddInitialGeneralElectionStates < ActiveRecord::Migration[8.1]
  def change
    GeneralElectionState.create( label: 'Pre-candidates' )
    GeneralElectionState.create( label: 'Candidates only' )
    GeneralElectionState.create( label: 'Winners only' )
    GeneralElectionState.create( label: 'Full results' )
  end
end
