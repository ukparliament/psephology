# == Schema Information
#
# Table name: enablings
#
#  id                      :integer          not null, primary key
#  enabled_legislation_id  :integer          not null
#  enabling_legislation_id :integer          not null
#
# Foreign Keys
#
#  fk_enabled_legislation   (enabled_legislation_id => legislation_items.id)
#  fk_enabling_legislation  (enabling_legislation_id => legislation_items.id)
#
class Enabling < ApplicationRecord
end
