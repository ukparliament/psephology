class PopulateStateOnGeneralElectionStetes < ActiveRecord::Migration[8.1]
  def change
    GeneralElectionState.all.each do |ges|
      ges.state = ges.id
      ges.save!
    end
  end
end
