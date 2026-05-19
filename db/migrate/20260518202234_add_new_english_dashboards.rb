class AddNewEnglishDashboards < ActiveRecord::Migration[8.1]
  def change
  
    # Create the school workforce dashboard ...
    dashboard = CommonsLibraryDashboard.new
    dashboard.title = 'School workforce'
    dashboard.url = 'https://commonslibrary.parliament.uk/constituency-data-school-workforce/'
    dashboard.save!
    
    # ,,, and link it to England only.
    dashboard_country = CommonsLibraryDashboardCountry.new
    dashboard_country.commons_library_dashboard = dashboard
    dashboard_country.country_id = 2
    dashboard_country.save!
    
    # Create the free school meals dashboard ...
    dashboard = CommonsLibraryDashboard.new
    dashboard.title = 'Free school meals'
    dashboard.url = 'https://commonslibrary.parliament.uk/constituency-data-free-school-meals/'
    dashboard.save!
    
    # ,,, and link it to England only.
    dashboard_country = CommonsLibraryDashboardCountry.new
    dashboard_country.commons_library_dashboard = dashboard
    dashboard_country.country_id = 2
    dashboard_country.save!
  end
end
