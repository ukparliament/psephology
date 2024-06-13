class MetaController < ApplicationController
  
  def index
    @page_title = 'Meta'
  end
  
  def coverage
    @page_title = 'Coverage: June 2024'
  end
  
  def roadmap
    @page_title = 'Roadmap'
  end
  
  def contact
    @page_title = 'Contact'
  end
  
  def cookies
    @page_title = 'Cookies'
  end
  
  def schema
    @page_title = 'Database schema'
  end
end
