# == Schema Information
#
# Table name: english_regions
#
#  id              :integer          not null, primary key
#  geographic_code :string(255)      not null
#  name            :string(255)      not null
#  country_id      :integer          not null
#
# Indexes
#
#  index_english_regions_on_country_id  (country_id)
#
# Foreign Keys
#
#  fk_country  (country_id => countries.id)
#
class EnglishRegion < ApplicationRecord
  
  belongs_to :country
end
