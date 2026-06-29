class UpdateCommonsLibraryDashboardUrls < ActiveRecord::Migration[8.1]
  def change
  
    dashboard = CommonsLibraryDashboard.find( 1 )
    dashboard.url = 'https://commonslibrary.parliament.uk/research-briefings/cbp-10897/'
    dashboard.save!
    
    dashboard = CommonsLibraryDashboard.find( 3 )
    dashboard.url = 'https://commonslibrary.parliament.uk/research-briefings/cbp-10868/'
    dashboard.save!
    
    dashboard = CommonsLibraryDashboard.find( 4 )
    dashboard.url = 'https://commonslibrary.parliament.uk/research-briefings/cbp-10873/'
    dashboard.save!
    
    dashboard = CommonsLibraryDashboard.find( 5 )
    dashboard.url = 'https://commonslibrary.parliament.uk/research-briefings/cbp-10891/'
    dashboard.save!
    
    dashboard = CommonsLibraryDashboard.find( 6 )
    dashboard.url = 'https://commonslibrary.parliament.uk/research-briefings/cbp-10894/'
    dashboard.save!
    
    dashboard = CommonsLibraryDashboard.find( 7 )
    dashboard.url = 'https://commonslibrary.parliament.uk/research-briefings/cbp-10872/'
    dashboard.save!
    
    dashboard = CommonsLibraryDashboard.find( 8 )
    dashboard.url = 'https://commonslibrary.parliament.uk/research-briefings/cbp-10882/'
    dashboard.save!
    
    dashboard = CommonsLibraryDashboard.find( 9 )
    dashboard.url = 'https://commonslibrary.parliament.uk/research-briefings/cbp-10875/'
    dashboard.save!
    
    dashboard = CommonsLibraryDashboard.find( 10 )
    dashboard.url = 'https://commonslibrary.parliament.uk/research-briefings/cbp-10874/'
    dashboard.save!
    
    dashboard = CommonsLibraryDashboard.new
    dashboard.title = 'Green belt land in England'
    dashboard.url = 'https://commonslibrary.parliament.uk/research-briefings/cbp-10898/'
    dashboard.save!
    
    dashboard_country = CommonsLibraryDashboardCountry.new
    dashboard_country.commons_library_dashboard = dashboard
    dashboard_country.country_id = 2
    dashboard_country.save!
  end
end
