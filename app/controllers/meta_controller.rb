class MetaController < ApplicationController
  
  def index
    @page_title = 'About this website'
    @description = 'About this website.'
    @crumb << { label: 'About this website', url: nil }
  end
  
  def coverage
    @page_title = 'Coverage: March 2026'
    @description = 'Elections to the United Kingdom Parliament covered by this website.'
    @crumb << { label: 'About this website', url: meta_list_url }
    @crumb << { label: 'Coverage', url: nil }
  end
  
  def roadmap
    @page_title = 'Roadmap'
    @description = 'The roadmap for development of this website.'
    @crumb << { label: 'About this website', url: meta_list_url }
    @crumb << { label: 'Roadmap', url: nil }
  end
  
  def contact
    @page_title = 'Contact'
    @description = 'How to contact us.'
    @crumb << { label: 'About this website', url: meta_list_url }
    @crumb << { label: 'Contact', url: nil }
  end
  
  def cookies
    @page_title = 'Cookies'
    @description = 'The cookie policy for this website.'
    @crumb << { label: 'About this website', url: meta_list_url }
    @crumb << { label: 'Cookies', url: nil }
  end
  
  def schema
    @page_title = 'Database schema'
    @description = 'An entity relationship diagram describing the database schema for this website.'
    @crumb << { label: 'About this website', url: meta_list_url }
    @crumb << { label: 'Database schema', url: nil }
  end
  
  def data_dictionary
    @page_title = 'Data dictionary'
    @description = 'A data dictionary for the election results database.'
    @crumb << { label: 'About this website', url: meta_list_url }
    @crumb << { label: 'Data dictionary', url: nil }
  end
  
  def verification
    @page_title = 'How we verify election results'
    @description = 'How the House of Commons Library verify election results.'
    @crumb << { label: 'About this website', url: meta_list_url }
    @crumb << { label: 'Result verification', url: nil }
  end
end
