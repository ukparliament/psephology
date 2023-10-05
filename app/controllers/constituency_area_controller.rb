class ConstituencyAreaController < ApplicationController
  
  def index
    @current_constituency_areas = current_constituency_areas
    @all_constituency_areas = all_constituency_areas
    @page_title = 'All constituencies'
    render :template => 'constituency_area/all'
  end
  
  def current
    @current_constituency_areas = current_constituency_areas
    @all_constituency_areas = all_constituency_areas
    @page_title = 'Current constituencies'
  end
  
  def all
    @current_constituency_areas = current_constituency_areas
    @all_constituency_areas = all_constituency_areas
    @page_title = 'All constituencies'
  end
  
  def show
    constituency_area = params[:constituency_area]
    @constituency_area = ConstituencyArea.find_by_sql(
      "
        SELECT ca.*, boundary_set.start_on AS start_on, boundary_set.end_on AS end_on, constituency_area_type.area_type, country.country_name, country.geography_code AS country_geography_code, english_region.english_region_name
        
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
          SELECT id AS country_id, name AS country_name, geography_code AS geography_code
          FROM countries
        ) country
        ON country.country_id = ca.country_id
        
        WHERE ca.geography_code = '#{constituency_area}'
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @constituency_area
    @page_title = @constituency_area.name_with_dates
    
    @elections = @constituency_area.elections
  end
end

def current_constituency_areas
  ConstituencyArea.find_by_sql(
    "
      SELECT ca.*
      FROM constituency_areas ca, boundary_sets bs
      WHERE ca.boundary_set_id = bs.id
      AND bs.end_on IS NULL
      ORDER BY ca.name
    "
  )
end

def all_constituency_areas
  ConstituencyArea.find_by_sql(
    "
      SELECT ca.*, bs.start_on AS start_on, bs.end_on AS end_on
      FROM constituency_areas ca, boundary_sets bs
      WHERE ca.boundary_set_id = bs.id
      ORDER BY ca.name
    "
  )
end
