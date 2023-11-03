class ActOfParliamentController < ApplicationController
  
  def index
    @acts_of_parliament = LegislationItem.find_by_sql(
      "
        SELECT li.*
        FROM legislation_items li, legislation_types lt
        WHERE li.legislation_type_id = lt.id
        AND lt.abbreviation = 'acts'
        ORDER BY li.statute_book_on DESC
      "
    )
    @page_title = "Acts of Parliament"
  end
end
