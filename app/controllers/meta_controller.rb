class MetaController < ApplicationController
  
  def index
    @page_title = 'Meta'
    @description = 'Information about this website.'
    @crumb << { label: 'Meta', url: nil }
  end
  
  def coverage
    @page_title = 'Coverage: July 2024'
    @description = 'Elections to the United Kingdom Parliament covered by this website.'
    @crumb << { label: 'Coverage', url: nil }
  end
  
  def roadmap
    @page_title = 'Roadmap'
    @description = 'The roadmap for development of this website.'
    @crumb << { label: 'Roadmap', url: nil }
  end
  
  def contact
    @page_title = 'Contact'
    @description = 'How to contact us.'
    @crumb << { label: 'Contact', url: nil }
  end
  
  def cookies
    @page_title = 'Cookies'
    @description = 'The cookie policy for this website.'
    @crumb << { label: 'Cookies', url: nil }
  end
  
  def schema
    @page_title = 'Database schema'
    @description = 'An entity relationship diagram describing the database schema for this website.'
    @crumb << { label: 'Database schema', url: nil }
  end
end
