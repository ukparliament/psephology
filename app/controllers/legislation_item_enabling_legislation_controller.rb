class LegislationItemEnablingLegislationController < ApplicationController
  
  def index
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
    raise ActiveRecord::RecordNotFound if @enabling_legislation.empty?
    
    @page_title = "Enabling legislation for the #{@legislation_item.title}"
    @multiline_page_title = "Legislation <span class='subhead'>Enabling legislation for the #{@legislation_item.title}</span>".html_safe
    @description = "Enabling legislation for the #{@legislation_item.title}."
    if @legislation_item.legislation_type_abbreviation == 'acts'
      @crumb << { label: 'Acts of Parliament', url: act_of_parliament_list_url }
    else
      @crumb << { label: 'Orders in Council', url: order_in_council_list_url }
    end
    @crumb << { label: @legislation_item.title, url: legislation_item_show_url }
    @crumb << { label: 'Enabling legislation', url: nil }
    @section = 'legislation'
  end
end
