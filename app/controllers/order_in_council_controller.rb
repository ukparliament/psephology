class OrderInCouncilController < ApplicationController
  
  def index
    @orders_in_council = LegislationItem.find_by_sql(
      "
        SELECT li.*
        FROM legislation_items li, legislation_types lt
        WHERE li.legislation_type_id = lt.id
        AND lt.abbreviation = 'orders'
        ORDER BY li.statute_book_on DESC
      "
    )
    
    @page_title = "Legislation - Orders in Council"
    @multiline_page_title = "Legislation <span class='subhead'>Orders in Council</span>".html_safe
    @description = 'Orders in Council which create new boundary sets, establishing new constituencies.'
    @csv_url = order_in_council_list_url( :format => 'csv' )
    @crumb << { label: 'Orders in Council', url: nil }
    @section = 'legislation'
    @subsection = 'orders-in-council'
  end
end
