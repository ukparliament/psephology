# == Schema Information
#
# Table name: parliament_periods
#
#  id                                                :integer          not null, primary key
#  commons_library_briefing_by_election_briefing_url :string(255)
#  dissolved_on                                      :date
#  london_gazette                                    :string(30)
#  number                                            :integer          not null
#  state_opening_on                                  :date
#  summoned_on                                       :date             not null
#  wikidata_id                                       :string(20)
#
class ParliamentPeriod < ApplicationRecord
  
  def display_dates
    display_dates = self.summoned_on.strftime( $DATE_DISPLAY_FORMAT )
    display_dates += ' - '
    display_dates += self.dissolved_on.strftime( $DATE_DISPLAY_FORMAT ) if self.dissolved_on
    display_dates
  end
  
  def general_election
    GeneralElection.find_by_sql([
      "
        SELECT *
        FROM general_elections
        WHERE parliament_period_id = ?
        AND is_notional IS FALSE
        AND polling_on <= CURRENT_DATE
      ", id
    ]).first
  end
  
  def by_elections
    Election.find_by_sql([
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg
        WHERE e.constituency_group_id = cg.id
        AND e.general_election_id IS NULL
        AND e.parliament_period_id = ?
        ORDER BY e.polling_on, constituency_group_name
      ", id
    ])
  end
  
  def maiden_speeches
    MaidenSpeech.find_by_sql([
      "
        SELECT ms.*,
          member.given_name AS member_given_name,
          member.family_name AS member_family_name,
          member.mnis_id AS member_mnis_id,
          constituency_group.name AS constituency_group_name,
          constituency_area_id AS constituency_area_id,
          parliament_period.number AS parliament_period_number
        
        FROM maiden_speeches ms
        
        INNER JOIN (
          SELECT *
          FROM members
        ) member
        ON member.id = ms.member_id
      
        INNER join (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = ms.constituency_group_id
      
        LEFT JOIN (
          SELECT *
          FROM constituency_areas
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
        
        INNER JOIN (
          SELECT *
          FROM parliament_periods
        ) parliament_period
        ON parliament_period.id = ms.parliament_period_id
      
        WHERE ms.parliament_period_id = ?
        ORDER BY ms.made_on
      ", id
    ])
  end
  
  def boundary_sets
    BoundarySet.find_by_sql([
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, constituency_areas ca, constituency_groups cg, elections e, countries c
        WHERE bs.id = ca.boundary_set_id
        AND cg.constituency_area_id = ca.id
        AND e.constituency_group_id = cg.id
        AND e.parliament_period_id = ?
        AND e.is_notional IS FALSE
        AND bs.country_id = c.id
        GROUP BY bs.id, c.name
        ORDER BY bs.start_on, c.name
        
      ", id
    ])
  end
  
  def boundary_sets_for_general_elections
    BoundarySet.find_by_sql([
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, countries c, general_election_in_boundary_sets geibs, general_elections ge
        WHERE bs.id = geibs.boundary_set_id
        AND bs.country_id = c.id
        AND geibs.general_election_id = ge.id
        AND ge.parliament_period_id = ?
        AND ge.is_notional IS FALSE
        ORDER BY bs.start_on, c.name
        
      ", id
    ])
  end
  
  def previous_parliament_period
    ParliamentPeriod.where( "summoned_on < ?", self.summoned_on ).order( "summoned_on desc" ).first
  end
  
  def next_parliament_period
    ParliamentPeriod.where( "summoned_on > ?", self.summoned_on ).order( "summoned_on" ).first
  end
  
  def london_gazette_issue_number
    self.london_gazette[6..-1]
  end
  
  def crumb_label
    parliament_period_crumb_label = self.number.ordinalize
    parliament_period_crumb_label += ' Parliament'
  end
end
