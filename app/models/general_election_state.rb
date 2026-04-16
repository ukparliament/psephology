# == Schema Information
#
# Table name: general_election_states
#
#  id         :bigint           not null, primary key
#  label      :string
#  state      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class GeneralElectionState < ApplicationRecord
end
