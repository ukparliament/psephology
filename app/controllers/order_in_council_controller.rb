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
    @page_title = "Orders in Council"
  end
end
