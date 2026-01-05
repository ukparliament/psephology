class RemoveInvalidVoteCountFromGeneralElections < ActiveRecord::Migration[8.1]
  def change
    remove_column :general_elections, :invalid_vote_count, :integer
  end
end
