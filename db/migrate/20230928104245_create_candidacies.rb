class CreateCandidacies < ActiveRecord::Migration[7.0]
  def change
    create_table :candidacies do |t|

      t.timestamps
    end
  end
end
