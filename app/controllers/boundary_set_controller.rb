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
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"boundary-sets.csv\""
      }
      format.html {
        # We create an array to hold only parent boundary sets.
        @parent_boundary_sets = []
    
        # For each boundary set ...
        @boundary_sets.each do |bs|
    
          # ... we add child boundary sets as an empty array.
          bs.child_boundary_sets = []
      
          # Unless the boundary set is a child boundary set ...
          unless bs.is_child_boundary_set?
      
            # ... we add the boundary set to the array of parent boundary sets.
            @parent_boundary_sets << bs
        
            # For each inner boundary set ...
            @boundary_sets.each do |bs2|
        
              # ... if the inner boundary set has a parent boundary set id of the outer boundary set ...
              if bs2.parent_boundary_set_id == bs.id
            
                # ... we add the inner boundary set to the array of child boundary sets.
                bs.child_boundary_sets << bs2
              end
            end
          end
        end
        
        @page_title = "Boundary sets"
        @description = 'Boundary sets establishing new constituencies.'
        @csv_url = boundary_set_list_url( :format => 'csv' )
        @crumb << { label: 'Boundary sets', url: nil }
        @section = 'boundary-sets'
      }
    end
  end
  
  def show
    @boundary_set = get_boundary_set
    
    @constituency_areas = @boundary_set.constituency_areas
    
    @parent_boundary_set = @boundary_set.parent_boundary_set if @boundary_set.is_child_boundary_set?
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - constituency areas"
    @multiline_page_title = "Boundary set for #{@boundary_set.display_title} <span class='subhead'>Constituency areas</span>".html_safe
    @description = "Constituency areas established by the #{@boundary_set.display_title} boundary set."
    @crumb << { label: 'Boundary sets', url: boundary_set_list_url }
    @crumb << { label: @boundary_set.display_title, url: nil }
    @section = 'boundary-sets'
    @subsection = 'constituency-areas'
    
    render :template => 'boundary_set_constituency_area/index'
  end
end
