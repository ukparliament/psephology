class AddGeneralElectionPublicationStateForeignKey < ActiveRecord::Migration[8.0]
  def change
    add_reference :general_elections, :general_election_publication_state, index: true, foreign_key: true
  end
end
