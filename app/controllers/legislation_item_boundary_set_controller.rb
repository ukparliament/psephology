class LegislationItemBoundarySetController < ApplicationController
  
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
    
    @boundary_sets = @legislation_item.boundary_sets
    raise ActiveRecord::RecordNotFound if @boundary_sets.empty?
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"boundary-sets-established-by-#{@legislation_item.title.downcase.gsub( ' ', '-' )}.csv\""
        render :template => 'boundary_set/index'
      }
      format.html {
        @page_title = "Legislation - Boundary sets established by the #{@legislation_item.title}"
        @multiline_page_title = "Legislation <span class='subhead'>Boundary sets established by the #{@legislation_item.title}</span>".html_safe
        @description = "Boundary sets established by the #{@legislation_item.title}."
        if @legislation_item.legislation_type_abbreviation == 'acts'
          @crumb << { label: 'Acts of Parliament', url: act_of_parliament_list_url }
        else
          @crumb << { label: 'Orders in Council', url: order_in_council_list_url }
        end
        @crumb << { label: @legislation_item.title, url: legislation_item_show_url }
        @crumb << { label: 'Boundary sets', url: nil }
        @section = 'legislation'
      }
    end
  end
end
