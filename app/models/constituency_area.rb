class ConstituencyArea < ApplicationRecord
  
  attr_accessor :election_array
  
  belongs_to :country
  belongs_to :english_region, optional: true
  belongs_to :constituency_area_type
  belongs_to :boundary_set, optional: true
  
  def is_current?
    is_current = false
    
    # A constituency area is current if it belongs to a boundary set, if that boundary set has a start date, if that start date is on or before today and if the boundary set has no end date.
    if self.boundary_set && self.boundary_set.start_on && self.boundary_set.start_on <= Date.today && self.boundary_set.end_on.nil?
      is_current = true
    end
    is_current
  end
  
  def name_with_dates
    name_with_dates = self.name
    if self.start_on
      name_with_dates += ' (' + self.start_on.strftime( $DATE_DISPLAY_FORMAT ) + ' - '
    else
      name_with_dates += ' (start date dependent on next dissolution'
    end
    name_with_dates += self.end_on.strftime( $DATE_DISPLAY_FORMAT ) if self.end_on
    name_with_dates += ')'
    name_with_dates
  end
  
  def name_with_years
    name_with_dates = self.name
    if self.start_on
      name_with_dates += ' (' + self.start_on.strftime( '%Y' ) + ' - '
    else
      name_with_dates += ' (start date dependent on next dissolution'
    end
    name_with_dates += self.end_on.strftime( '%Y' ) if self.end_on
    name_with_dates += ')'
    name_with_dates
  end
  
  def elections
    Election.find_by_sql(
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg
        WHERE e.constituency_group_id = cg.id
        AND cg.constituency_area_id = #{self.id}
        AND e.is_notional IS FALSE
        ORDER BY e.polling_on desc
      "
    )
  end
  
  def notional_elections
    Election.find_by_sql(
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg
        WHERE e.constituency_group_id = cg.id
        AND cg.constituency_area_id = #{self.id}
        AND e.is_notional IS TRUE
        ORDER BY e.polling_on desc
      "
    )
  end
  
  def commons_library_dashboards
    
    # If the constituency area is a current constituency area ...
    if self.is_current?
      
      # ... we get the Commons Library dashboards ...
      commons_library_dashboard = CommonsLibraryDashboard.find_by_sql(
        "
          SELECT cld.*
          FROM commons_library_dashboards cld, commons_library_dashboard_countries cldc, countries c
          WHERE cld.id = cldc.commons_library_dashboard_id
          AND cldc.country_id = c.id
          AND c.id = #{self.country_id}
        "
      )
    
    # Otherwise, if the constituency area is not current ...
    else
      
      # ... we set the Commons Library dashboards to an empty array.
      commons_library_dashboard = []
    end
    commons_library_dashboard
  end
  
  def overlaps_from
    ConstituencyAreaOverlap.find_by_sql(
      "
        SELECT cao.*, ca.name AS constituency_area_name, bs.start_on, bs.end_on
        FROM constituency_area_overlaps cao, constituency_areas ca, boundary_sets bs
        WHERE cao.to_constituency_area_id = #{self.id}
        AND cao.from_constituency_area_id = ca.id
        AND ca.boundary_set_id = bs.id
        ORDER BY cao.from_constituency_residential DESC
      "
    )
  end
  
  def overlaps_to
    @overlaps_to = ConstituencyAreaOverlap.find_by_sql(
      "
        SELECT cao.*, ca.name AS constituency_area_name, bs.start_on, bs.end_on
        FROM constituency_area_overlaps cao, constituency_areas ca, boundary_sets bs
        WHERE cao.from_constituency_area_id = #{self.id}
        AND cao.to_constituency_area_id = ca.id
        AND ca.boundary_set_id = bs.id
        ORDER BY cao.to_constituency_residential DESC
      "
    )
  end
  
  def has_ons_stats?
    has_ons_stats = false
    if self.country_name == 'England' or self.country_name == 'Wales'
      has_ons_stats = true
    end
    has_ons_stats
  end
end
