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
    
    @page_title = "Legislation - Acts of Parliament"
    @multiline_page_title = "Legislation <span class='subhead'>Acts of Parliament</span>".html_safe
    @description = 'Acts of Parliament which create new boundary sets, or delegate powers to Orders in Council to create new boundary sets, establishing new constituencies.'
    @csv_url = act_of_parliament_list_url( :format => 'csv' )
    @crumb << { label: 'Acts of Parliament', url: nil }
    @section = 'legislation'
    @subsection = 'acts-of-parliament'
  end
end
