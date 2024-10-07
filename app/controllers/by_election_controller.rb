class ByElectionController < ApplicationController
  
  def index
    @by_elections = Election.find_by_sql(
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg
        WHERE e.constituency_group_id = cg.id
        AND general_election_id IS NULL
        ORDER BY polling_on DESC, constituency_group_name
      "
    )
    
    @election_listing_items = Election.find_by_sql(
      "
        SELECT e.*,
          parliament_period.number AS parliament_period_number,
          parliament_period.summoned_on AS parliament_period_summoned_on,
          parliament_period.dissolved_on AS parliament_period_dissolved_on,
          parliament_period.wikidata_id AS parliament_period_wikidata_id,
          parliament_period.london_gazette AS parliament_period_london_gazette,
          parliament_period.id AS parliament_period_id,
          constituency_group.name AS constituency_group_name,
          constituency_area.geographic_code AS constituency_area_geographic_code,
          constituency_area.area_type AS constituency_area_type,
          constituency_area.id AS constituency_area_id,
          'By-election' AS type
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM parliament_periods
        ) parliament_period
        ON parliament_period.id = e.parliament_period_id
        
        INNER JOIN (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        LEFT JOIN (
          SELECT ca.*, cat.area_type
          FROM constituency_areas ca, constituency_area_types cat
          WHERE ca.constituency_area_type_id = cat.id
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
        
        WHERE e.general_election_id IS NULL
        
        ORDER BY polling_on DESC, constituency_group_name
      "
    )
    
    @page_title = 'By-elections'
    @description = 'By-elections to the Parliament of the United Kingdom.'
    @crumb << { label: 'By-elections', url: nil }
    @section = 'by-elections'
  end
end
