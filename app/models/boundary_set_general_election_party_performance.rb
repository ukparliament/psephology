# == Schema Information
#
# Table name: boundary_set_general_election_party_performances
#
#  id                           :integer          not null, primary key
#  constituency_contested_count :integer          not null
#  constituency_won_count       :integer          not null
#  cumulative_vote_count        :integer          not null
#  boundary_set_id              :integer          not null
#  general_election_id          :integer          not null
#  political_party_id           :integer          not null
#
# Foreign Keys
#
#  fk_boundary_set      (boundary_set_id => boundary_sets.id)
#  fk_general_election  (general_election_id => general_elections.id)
#  fk_political_party   (political_party_id => political_parties.id)
#  fk_rails_...         (general_election_id => general_elections.id) ON DELETE => cascade
#
class BoundarySetGeneralElectionPartyPerformance < ApplicationRecord
  
  belongs_to :general_election
  belongs_to :political_party
  belongs_to :boundary_set
end
