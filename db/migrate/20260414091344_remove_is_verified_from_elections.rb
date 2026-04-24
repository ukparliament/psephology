class RemoveIsVerifiedFromElections < ActiveRecord::Migration[8.1]
  def change
    remove_column :elections, :is_verified, :boolean
  end
end
