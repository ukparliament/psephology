# == Schema Information
#
# Table name: legislation_types
#
#  id           :integer          not null, primary key
#  abbreviation :string(10)       not null
#  label        :string(255)      not null
#
class LegislationType < ApplicationRecord
end
