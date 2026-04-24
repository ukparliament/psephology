class PopulateStateOnElectionStates < ActiveRecord::Migration[8.1]
  def change
    ElectionState.all.each do |es|
      es.state = es.id
      es.save!
    end
  end
end
