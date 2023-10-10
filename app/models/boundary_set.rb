class BoundarySet < ApplicationRecord
  
  belongs_to :country
  belongs_to :order_in_council
  
  def display_title
    display_title = self.country_name
    display_title += ' (' + self.start_on.strftime( $DATE_DISPLAY_FORMAT ) + ' - ' 
    display_title += self.end_on.strftime( $DATE_DISPLAY_FORMAT ) if self.end_on
    display_title += ')'
    display_title
  end
  
  def display_dates
    display_dates = self.start_on.strftime( $DATE_DISPLAY_FORMAT ) + ' - ' 
    display_dates += self.end_on.strftime( $DATE_DISPLAY_FORMAT ) if self.end_on
    display_dates
  end
  
  def general_elections
    GeneralElection.find_by_sql(
      "
        SELECT ge.*
        FROM general_elections ge, elections e, constituency_groups cg, constituency_areas ca, boundary_sets bs
        WHERE e.general_election_id = ge.id
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.boundary_set_id = bs.id
        GROUP BY ge.id
        ORDER BY ge.polling_on
      "
    )
  end
  
  def constituency_areas
    ConstituencyArea.find_by_sql(
      "
        SELECT *
        FROM constituency_areas
        WHERE boundary_set_id = #{self.id}
        ORDER BY name
      "
    )
  end
  
  def elections
    Election.find_by_sql(
      "
        SELECT e.*, ca.id AS constituency_area_id, ( cast(e.majority as decimal) / e.valid_vote_count ) AS majority_percentage
        FROM elections e, constituency_groups cg, constituency_areas ca
        WHERE e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.boundary_set_id = #{self.id}
        ORDER BY e.polling_on
      "
    )
  end
  
  def elections_with_electorate
    Election.find_by_sql(
      "
        SELECT e.*, ca.id AS constituency_area_id, ( cast(e.majority as decimal) / e.valid_vote_count ) AS majority_percentage, elec.population_count AS electorate_population_count
        FROM elections e, constituency_groups cg, constituency_areas ca, electorates elec
        WHERE e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.boundary_set_id = #{self.id}
        AND e.electorate_id = elec.id
        ORDER BY e.polling_on
      "
    )
  end
end
