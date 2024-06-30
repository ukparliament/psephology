class MetaController < ApplicationController
  
  def index
    @page_title = 'Meta'
    @description = 'Meta.'
    @crumb = '<li>Meta</li>'
  end
  
  def coverage
    @page_title = 'Coverage: June 2024'
    @description = 'Content coverage.'
    @crumb = '<li>Coverage</li>'
  end
  
  def roadmap
    @page_title = 'Roadmap'
    @description = 'Our roadmap.'
    @crumb = '<li>Roadmap</li>'
  end
  
  def contact
    @page_title = 'Contact'
    @description = 'Contact us.'
    @crumb = '<li>Contact</li>'
  end
  
  def cookies
    @page_title = 'Cookies'
    @description = 'Cookie policy.'
    @crumb = '<li>Cookies</li>'
  end
  
  def schema
    @page_title = 'Database schema'
    @description = 'Database schema.'
    @crumb = '<li>Database schema</li>'
  end
end
