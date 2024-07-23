class LegislationItemController < ApplicationController
  
  def index
    @legislation_items = LegislationItem.all.order( 'statute_book_on desc' )
    
    @page_title = 'Legislation'
    @description = "Legislation"
    @crumb << { label: 'Legislation', url: nil }
    @section = 'legislation'
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
    @description = "#{@legislation_item.title}."
    if @legislation_item.legislation_type_abbreviation == 'acts'
      @crumb << { label: 'Acts of Parliament', url: act_of_parliament_list_url }
    else
      @crumb << { label: 'Orders in Council', url: order_in_council_list_url }
    end
    @crumb << { label: @legislation_item.title, url: nil }
    @section = 'legislation'
  end
end
