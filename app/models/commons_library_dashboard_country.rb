# == Schema Information
#
# Table name: commons_library_dashboard_countries
#
#  id                           :integer          not null, primary key
#  commons_library_dashboard_id :integer          not null
#  country_id                   :integer          not null
#
# Foreign Keys
#
#  fk_commons_library_dashboard  (commons_library_dashboard_id => commons_library_dashboards.id)
#  fk_country                    (country_id => countries.id)
#
class CommonsLibraryDashboardCountry < ApplicationRecord
  
  belongs_to :commons_library_dashboard
  belongs_to :country
end
