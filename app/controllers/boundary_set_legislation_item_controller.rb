class BoundarySetLegislationItemController < ApplicationController
  
  def index
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
    
    # We get the establishing legislation for the boundary set.
    @establishing_legislation = @boundary_set.establishing_legislation
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - establishing legislation"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>Establishing legislation</span>".html_safe
    
    @section = 'boundary-sets'
    @subsection = 'establishing-legislation'
    @description = "Legislation establishing the #{@boundary_set.display_title} boundary set."
    @crumb = "<li><a href='/boundary-sets'>Boundary sets</a></li>"
    @crumb += "<li><a href='/boundary-sets/#{@boundary_set.id}'>" + @boundary_set.display_title + '</a></li>'
    @crumb += '<li>Establishing legislation</li>'
  end
end
