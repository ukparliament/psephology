class ParliamentPeriod < ApplicationRecord
  
  def display_dates
    display_dates = self.summoned_on.strftime( $DATE_DISPLAY_FORMAT )
    display_dates += ' - '
    display_dates += self.dissolved_on.strftime( $DATE_DISPLAY_FORMAT ) if self.dissolved_on
    display_dates
  end
  
  def general_elections
    GeneralElection.all.where( "parliament_period_id = ?", self.id ).where( 'is_notional IS FALSE' )
  end
  
  def by_elections
    Election.find_by_sql(
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg
        WHERE e.constituency_group_id = cg.id
        AND e.general_election_id IS NULL
        ORDER BY e.polling_on, constituency_group_name
      "
    )
  end
  
  def boundary_sets
    BoundarySet.find_by_sql(
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, constituency_areas ca, constituency_groups cg, elections e, countries c
        WHERE bs.id = ca.boundary_set_id
        AND cg.constituency_area_id = ca.id
        AND e.constituency_group_id = cg.id
        AND e.parliament_period_id = #{self.id}
        AND e.is_notional IS FALSE
        AND bs.country_id = c.id
        GROUP BY bs.id, c.name
        ORDER BY bs.start_on, c.name
        
      "
    )
  end
  
  def previous_parliament_period
    ParliamentPeriod.where( "summoned_on < ?", self.summoned_on ).order( "summoned_on desc" ).first
  end
  
  def next_parliament_period
    ParliamentPeriod.where( "summoned_on > ?", self.summoned_on ).order( "summoned_on" ).first
  end
end
