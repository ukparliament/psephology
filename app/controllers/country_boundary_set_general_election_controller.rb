class CountryBoundarySetGeneralElectionController < ApplicationController
  
  def index
    country = params[:country]
    boundary_set = params[:boundary_set]
    boundary_set_date = Date.parse( boundary_set )
    @boundary_set = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name, oic.title AS order_in_council_title
        FROM boundary_sets bs, countries c, orders_in_council oic
        WHERE start_on = '#{boundary_set_date}'
        AND bs.country_id = c.id
        AND c.geography_code = '#{country}'
        AND oic.id = bs.order_in_council_id
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @boundary_set
    @general_elections = @boundary_set.general_elections
    @page_title = "Boundary set for #{@boundary_set.display_title} - general elections"
  end
  
  def majority
    country = params[:country]
    boundary_set = params[:boundary_set]
    boundary_set_date = Date.parse( boundary_set )
    @boundary_set = BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name, oic.title AS order_in_council_title
        FROM boundary_sets bs, countries c, orders_in_council oic
        WHERE start_on = '#{boundary_set_date}'
        AND bs.country_id = c.id
        AND c.geography_code = '#{country}'
        AND oic.id = bs.order_in_council_id
      "
    ).first
    raise ActiveRecord::RecordNotFound unless @boundary_set
    @general_elections = @boundary_set.general_elections
    @constituency_areas = @boundary_set.constituency_areas
    @elections = @boundary_set.elections
    
    @constituency_areas.each do |constituency_area|
      constituency_area.election_array = []
      @elections.each do |election|
        if election.constituency_area_id == constituency_area.id
          constituency_area.election_array << election
        end
      end
    end
    
    
    
    @page_title = "Boundary set for #{@boundary_set.display_title} - general elections by majority"
  end
end
