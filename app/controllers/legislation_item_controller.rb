class LegislationItemController < ApplicationController
  
  def index
    @page_title = 'Legislation'
    @legislation_items = LegislationItem.all.order( 'statute_book_on desc' )
  end
  
  def show
    legislation_item = params[:legislation_item]
    @legislation_item = LegislationItem.find_by_sql(
      "
        SELECT li.*, lt.abbreviation AS legislation_type_abbreviation
        FROM legislation_items li, legislation_types lt
        WHERE li.url_key = '#{legislation_item}'
        AND li.legislation_type_id = lt.id
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @legislation_item
    
    @enabling_legislation = @legislation_item.enabling_legislation
    @enabled_legislation = @legislation_item.enabled_legislation
    @boundary_sets = @legislation_item.boundary_sets
    
    @page_title = "Legislation - #{@legislation_item.title}"
    @multiline_page_title = "Legislation <span class='subhead'>#{@legislation_item.title}</span>".html_safe
    
    @section = 'legislation'
    if @legislation_item.legislation_type_abbreviation == 'acts'
      @crumb = "<li><a href='/acts-of-parliament'>Acts of Parliament</a></li>"
      @crumb += "<li>" + @legislation_item.title + "</li>"
    else
      @crumb = "<li><a href='/orders-in-council'>Orders in Council</a></li>"
      @crumb += "<li>" + @legislation_item.title + "</li>"
    end
    @description = "#{@legislation_item.title}."
  end
end
