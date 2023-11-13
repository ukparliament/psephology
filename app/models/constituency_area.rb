class ConstituencyArea < ApplicationRecord
  
  attr_accessor :election_array
  
  belongs_to :country
  belongs_to :english_region, optional: true
  belongs_to :constituency_area_type
  belongs_to :boundary_set, optional: true
  
  def name_with_dates
    name_with_dates = self.name
    name_with_dates += ' (' + self.start_on.strftime( $DATE_DISPLAY_FORMAT ) + ' - '
    name_with_dates += self.end_on.strftime( $DATE_DISPLAY_FORMAT ) if self.end_on
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
        ORDER BY e.polling_on desc
      "
    )
  end
  
  def commons_library_dashboards
    CommonsLibraryDashboard.find_by_sql(
      "
        SELECT cld.*
        FROM commons_library_dashboards cld, commons_library_dashboard_countries cldc, countries c
        WHERE cld.id = cldc.commons_library_dashboard_id
        AND cldc.country_id = c.id
        AND c.id = #{self.country_id}
      "
    )
  end
end
