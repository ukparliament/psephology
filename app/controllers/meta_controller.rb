class MetaController < ApplicationController
  
  def index
    @page_title = 'Meta'
    @description = 'Information about this website.'
    @crumb = '<li>Meta</li>'
  end
  
  def coverage
    @page_title = 'Coverage: June 2024'
    @description = 'Elections to the United Kingdom Parliament covered by this website.'
    @crumb = '<li>Coverage</li>'
  end
  
  def roadmap
    @page_title = 'Roadmap'
    @description = 'The roadmap for development of this website.'
    @crumb = '<li>Roadmap</li>'
  end
  
  def contact
    @page_title = 'Contact'
    @description = 'How to contact us.'
    @crumb = '<li>Contact</li>'
  end
  
  def cookies
    @page_title = 'Cookies'
    @description = 'The cookie policy for this website.'
    @crumb = '<li>Cookies</li>'
  end
  
  def schema
    @page_title = 'Database schema'
    @description = 'An entity relationship diagram describing the database schema for this website.'
    @crumb = '<li>Database schema</li>'
  end
end
