class CreateCertifications < ActiveRecord::Migration[7.0]
  def change
    create_table :certifications do |t|

      t.timestamps
    end
  end
end
