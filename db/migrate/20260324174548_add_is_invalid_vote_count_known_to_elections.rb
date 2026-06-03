class AddIsInvalidVoteCountKnownToElections < ActiveRecord::Migration[8.1]
  def change
    add_column :elections, :is_invalid_vote_count_known, :boolean, default: true
  end
end
