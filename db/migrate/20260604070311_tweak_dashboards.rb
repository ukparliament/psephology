class TweakDashboards < ActiveRecord::Migration[8.1]
  def change
  
    # We update the URL of the GPs and GP practices dashboard.
    dashboard = CommonsLibraryDashboard.find( 2 )
    dashboard.url = 'https://commonslibrary.parliament.uk/research-briefings/cbp-10824/'
    dashboard.save!
    
    # We add the wards and parishes briefing ...
    dashboard = CommonsLibraryDashboard.new
    dashboard.title = 'Wards and parishes'
    dashboard.url = 'https://commonslibrary.parliament.uk/research-briefings/cbp-10555/'
    dashboard.save!
    
    # ... and link it to England, Northern Ireland, Scotland and Wales.
    dashboard_country = CommonsLibraryDashboardCountry.new
    dashboard_country.commons_library_dashboard = dashboard
    dashboard_country.country_id = 2
    dashboard_country.save!
    dashboard_country = CommonsLibraryDashboardCountry.new
    dashboard_country.commons_library_dashboard = dashboard
    dashboard_country.country_id = 4
    dashboard_country.save!
    dashboard_country = CommonsLibraryDashboardCountry.new
    dashboard_country.commons_library_dashboard = dashboard
    dashboard_country.country_id = 5
    dashboard_country.save!
    dashboard_country = CommonsLibraryDashboardCountry.new
    dashboard_country.commons_library_dashboard = dashboard
    dashboard_country.country_id = 6
    dashboard_country.save!
    
    # We create the special educational needs and disabilities dashboard ...
    dashboard = CommonsLibraryDashboard.new
    dashboard.title = 'Special educational needs and disabilities'
    dashboard.url = 'https://commonslibrary.parliament.uk/research-briefings/cbp-10583/'
    dashboard.save!
    
    # ... and link it to England.
    dashboard_country = CommonsLibraryDashboardCountry.new
    dashboard_country.commons_library_dashboard = dashboard
    dashboard_country.country_id = 2
    dashboard_country.save!
  end
end
