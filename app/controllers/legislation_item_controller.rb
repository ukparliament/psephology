class LegislationItemController < ApplicationController
  
  def index
    @page_title = 'Legislation'
    @legislation_items = LegislationItem.all.order( 'statute_book_on desc' )
  end
  
  def show
    legislation_item = params[:legislation_item]
    @legislation_item = LegislationItem.find_by_url_key( legislation_item )
    raise ActiveRecord::RecordNotFound unless @legislation_item
    
    @enabling_legislation = @legislation_item.enabling_legislation
    @enabled_legislation = @legislation_item.enabled_legislation
    @boundary_sets = @legislation_item.boundary_sets
    

    
    @page_title = "Legislation - #{@legislation_item.title}"
    @multiline_page_title = "Legislation <span class='subhead'>#{@legislation_item.title}</span>".html_safe
  end
end
