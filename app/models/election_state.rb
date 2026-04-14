# == Schema Information
#
# Table name: election_states
#
#  id         :bigint           not null, primary key
#  label      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ElectionState < ApplicationRecord
end
