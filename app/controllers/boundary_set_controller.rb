class BoundarySetController < ApplicationController
  
  def index
    @countries = Country.find_by_sql(
      "
        SELECT c.*
        FROM countries c
        WHERE parent_country_id IS NULL
        ORDER BY c.name
      "
    )
    @boundary_sets = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name, c.geographic_code AS country_geographic_code
        FROM boundary_sets bs, countries c
        WHERE bs.country_id = c.id
        ORDER BY start_on DESC, country_name
      "
    )
    @page_title = "Boundary sets"
    @section = 'boundary-sets'
    @description = 'Boundary sets establishing new constituencies.'
    @crumb = "<li>Boundary sets</li>".html_safe
  end
  
  def show
    boundary_set = params[:boundary_set]
    
    @boundary_set = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, countries c
        WHERE bs.country_id = c.id
        AND bs.id = #{boundary_set}
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @boundary_set
    
    @constituency_areas = @boundary_set.constituency_areas
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - constituency areas"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>Constituency areas</span>".html_safe
    
    @section = 'boundary-sets'
    @subsection = 'constituency-areas'
    @description = "Constituency areas established by the #{@boundary_set.display_title} boundary set."
    @crumb = "<li><a href='/boundary-sets'>Boundary sets</a></li>"
    @crumb += '<li>' + @boundary_set.display_title + '</li>'
  end
end
