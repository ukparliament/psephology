# == Schema Information
#
# Table name: general_election_in_boundary_sets
#
#  id                  :integer          not null, primary key
#  ordinality          :integer          not null
#  boundary_set_id     :integer          not null
#  general_election_id :integer          not null
#
# Indexes
#
#  index_general_election_in_boundary_sets_on_boundary_set_id  (boundary_set_id)
#
# Foreign Keys
#
#  fk_parent_boundary_set      (boundary_set_id => boundary_sets.id)
#  fk_parent_general_election  (general_election_id => general_elections.id)
#  fk_rails_...                (general_election_id => general_elections.id) ON DELETE => cascade
#
class GeneralElectionInBoundarySet < ApplicationRecord
  
  belongs_to :general_election
  belongs_to :boundary_set
end
