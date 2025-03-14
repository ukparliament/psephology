class LegislationItemEnablingLegislationController < ApplicationController
  
  def index
    @legislation_item = get_legislation_item

    @legislation_items = @legislation_item.enabling_legislation
    raise ActiveRecord::RecordNotFound if @legislation_items.empty?
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"enabling-legislation-for-#{@legislation_item.title.downcase.gsub( ' ', '-' )}.csv\""
        render :template => 'legislation_item/index'
      }
      format.html {
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
      }
    end
  end
end
