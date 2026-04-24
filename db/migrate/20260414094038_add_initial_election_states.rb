class AddInitialElectionStates < ActiveRecord::Migration[8.1]
  def change
    ElectionState.create( label: 'Pre-candidates' )
    ElectionState.create( label: 'Candidates only' )
    ElectionState.create( label: 'Winners only' )
    ElectionState.create( label: 'Full results' )
  end
end
