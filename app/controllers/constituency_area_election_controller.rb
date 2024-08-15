class ConstituencyAreaElectionController < ApplicationController
  
  def index
    constituency_area = params[:constituency_area]
    @constituency_area = ConstituencyArea.find_by_sql(
      "
        SELECT ca.*, boundary_set.start_on AS start_on, boundary_set.end_on AS end_on, constituency_area_type.area_type, country.country_name, country.geographic_code AS country_geographic_code, english_region.english_region_name
        
        FROM constituency_areas ca
        
        LEFT JOIN (
          SELECT id AS english_region_id, name AS english_region_name
          FROM english_regions
        ) AS english_region
        ON english_region.english_region_id = ca.english_region_id
        
        INNER JOIN (
          SELECT id AS boundary_set_id, start_on, end_on
          FROM boundary_sets
        ) boundary_set
        ON boundary_set.boundary_set_id = ca.boundary_set_id
        
        INNER JOIN (
          SELECT id AS constituency_area_type_id, area_type
          FROM constituency_area_types
        ) constituency_area_type
        ON constituency_area_type.constituency_area_type_id = ca.constituency_area_type_id
        
        INNER JOIN (
          SELECT id AS country_id, name AS country_name, geographic_code AS geographic_code
          FROM countries
        ) country
        ON country.country_id = ca.country_id
        
        WHERE ca.id = '#{constituency_area}'
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @constituency_area
    
    @elections = @constituency_area.elections_with_details
    
    @page_title = "Elections in #{@constituency_area.name_with_dates}"
    @multiline_page_title = "#{@constituency_area.name_with_dates} <span class='subhead'>Elections</span>".html_safe
    @description = "Elections in the United Kingdom constituency area of #{@constituency_area.name_with_dates}."
    @crumb << { label: 'Constituency areas', url: constituency_area_list_current_url }
    @crumb << { label: @constituency_area.name_with_years, url: constituency_area_show_url }
    @crumb << { label: 'Elections', url: nil }
    @section = 'constituency-areas'
    @subsection = 'elections'
  end
end
