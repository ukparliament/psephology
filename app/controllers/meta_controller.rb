class MetaController < ApplicationController
  
  def index
    @page_title = 'Meta'
  end
  
  def about
    @page_title = 'About'
  end
  
  def schema
    @page_title = 'Schema'
  end
end
