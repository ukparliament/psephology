class AddIsVerifiedToElections < ActiveRecord::Migration[8.1]
  def change
    add_column :elections, :is_verified, :boolean, :default => true
  end
end
