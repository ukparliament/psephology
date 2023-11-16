class MetaController < ApplicationController
  
  def index
    @page_title = 'Meta'
  end
  
  def schema
    @page_title = 'Schema'
  end
end
