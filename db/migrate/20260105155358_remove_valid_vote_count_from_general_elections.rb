class RemoveValidVoteCountFromGeneralElections < ActiveRecord::Migration[8.1]
  def change
    remove_column :general_elections, :valid_vote_count, :integer
  end
end
