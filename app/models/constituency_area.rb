# == Schema Information
#
# Table name: constituency_areas
#
#  id                               :integer          not null, primary key
#  geographic_code                  :string(255)      not null
#  is_geographic_code_issued_by_ons :boolean          default(TRUE)
#  name                             :string(255)      not null
#  boundary_set_id                  :integer
#  constituency_area_type_id        :integer          not null
#  country_id                       :integer          not null
#  english_region_id                :integer
#  mnis_id                          :integer
#
# Indexes
#
#  index_constituency_areas_on_boundary_set_id            (boundary_set_id)
#  index_constituency_areas_on_constituency_area_type_id  (constituency_area_type_id)
#  index_constituency_areas_on_country_id                 (country_id)
#  index_constituency_areas_on_english_region_id          (english_region_id)
#
# Foreign Keys
#
#  fk_boundary_set            (boundary_set_id => boundary_sets.id)
#  fk_constituency_area_type  (constituency_area_type_id => constituency_area_types.id)
#  fk_country                 (country_id => countries.id)
#  fk_english_region          (english_region_id => english_regions.id)
#
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
    Election.find_by_sql([
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg
        WHERE e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ?
        AND e.is_notional IS FALSE
        ORDER BY e.polling_on desc
      ", id
    ])
  end
  
  def elections_with_details
    Election.find_by_sql([
      "
        SELECT
          e.*,
          result_summary.short_summary AS result_summary_short_summary,
          electorate.population_count AS electorate_population_count,
          winning_candidacy.candidate_family_name AS winning_candidacy_candidate_family_name,
          winning_candidacy.candidate_given_name AS winning_candidacy_candidate_given_name,
          winning_candidacy.vote_count AS winning_candidacy_vote_count,
          winning_candidacy.vote_share AS winning_candidacy_vote_share,
          winning_candidacy.vote_change AS winning_candidacy_vote_change,
          winning_candidacy.mnis_id AS winning_candidacy_mnis_id,
          winning_candidacy.is_standing_as_commons_speaker AS winning_candidacy_is_standing_as_commons_speaker,
          winning_candidacy.is_standing_as_independent AS winning_candidacy_is_standing_as_independent,
          winning_candidacy_main_party.id AS winning_candidacy_main_party_id,
          winning_candidacy_main_party.name AS winning_candidacy_main_party_name,
          winning_candidacy_main_party.abbreviation AS winning_candidacy_main_party_abbreviation,
          winning_candidacy_main_party.mnis_id AS winning_candidacy_main_party_mnis_id,
          winning_candidacy_adjunct_party.id AS winning_candidacy_adjunct_party_id,
          winning_candidacy_adjunct_party.name AS winning_candidacy_adjunct_party_name,
          winning_candidacy_adjunct_party.abbreviation AS winning_candidacy_adjunct_party_abbreviation
          
        FROM elections e
        
        INNER JOIN (
          SELECT cg.id
          FROM constituency_groups cg
          WHERE cg.constituency_area_id = ?
        ) constituency_group
        on constituency_group.id = e.constituency_group_id
        
        INNER JOIN (
          SELECT *
          FROM result_summaries
        ) result_summary
        ON e.result_summary_id = result_summary.id
        
        INNER JOIN (
          SELECT *
          FROM electorates
        ) electorate
        ON e.electorate_id = electorate.id
        
        INNER JOIN (
          SELECT c.*, m.mnis_id
          FROM candidacies c, members m
          WHERE c.is_winning_candidacy IS TRUE
          AND c.member_id = m.id
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
        
        LEFT JOIN (
          SELECT pp.*, cert.candidacy_id AS candidacy_id
          FROM political_parties pp, certifications cert
          WHERE pp.id = cert.political_party_id
          AND cert.adjunct_to_certification_id IS NULL
        ) winning_candidacy_main_party
        ON winning_candidacy_main_party.candidacy_id = winning_candidacy.id
        
        LEFT JOIN (
          SELECT pp.*, cert.candidacy_id AS candidacy_id
          FROM political_parties pp, certifications cert
          WHERE pp.id = cert.political_party_id
          AND cert.adjunct_to_certification_id IS NOT NULL
        ) winning_candidacy_adjunct_party
        ON winning_candidacy_adjunct_party.candidacy_id = winning_candidacy.id
        
        WHERE e.is_notional IS FALSE
        ORDER BY e.polling_on desc
      ", id
    ])
  end
  
  def notional_elections
    Election.find_by_sql([
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg
        WHERE e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ?
        AND e.is_notional IS TRUE
        ORDER BY e.polling_on desc
      ", id
    ])
  end
  
  def commons_library_dashboards
    
    # If the constituency area is a current constituency area ...
    if self.is_current?
      
      # ... we get the Commons Library dashboards ...
      commons_library_dashboard = CommonsLibraryDashboard.find_by_sql([
        "
          SELECT cld.*
          FROM commons_library_dashboards cld, commons_library_dashboard_countries cldc, countries c
          WHERE cld.id = cldc.commons_library_dashboard_id
          AND cldc.country_id = c.id
          AND c.id = ?
          ORDER BY cld.title
        ", country_id
      ])
    
    # Otherwise, if the constituency area is not current ...
    else
      
      # ... we set the Commons Library dashboards to an empty array.
      commons_library_dashboard = []
    end
    commons_library_dashboard
  end
  
  def overlaps_from
    ConstituencyAreaOverlap.find_by_sql([
      "
        SELECT cao.*, ca.name AS constituency_area_name, bs.start_on, bs.end_on
        FROM constituency_area_overlaps cao, constituency_areas ca, boundary_sets bs
        WHERE cao.to_constituency_area_id = ?
        AND cao.from_constituency_area_id = ca.id
        AND ca.boundary_set_id = bs.id
        ORDER BY cao.from_constituency_residential DESC
      ", id
    ])
  end
  
  def overlaps_to
    @overlaps_to = ConstituencyAreaOverlap.find_by_sql([
      "
        SELECT cao.*, ca.name AS constituency_area_name, bs.start_on, bs.end_on
        FROM constituency_area_overlaps cao, constituency_areas ca, boundary_sets bs
        WHERE cao.from_constituency_area_id = ?
        AND cao.to_constituency_area_id = ca.id
        AND ca.boundary_set_id = bs.id
        ORDER BY cao.to_constituency_residential DESC
      ", id
    ])
  end
  
  def has_ons_stats?
    has_ons_stats = false
    if self.country_name == 'England' or self.country_name == 'Wales'
      has_ons_stats = true
    end
    has_ons_stats
  end
  
  def display_details_page?( elections, notional_elections, commons_library_dashboards, overlaps_from, overlaps_to )
    display_details_page = true
    
    if elections.empty? && notional_elections.empty? && commons_library_dashboards.empty? && !self.has_ons_stats? && overlaps_from.empty? && overlaps_to.empty?
      display_details_page = false
    end
    
    display_details_page
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
        
        
      
        WHERE constituency_group.constituency_area_id = ?
        ORDER BY ms.made_on
      ", id
    ])
  end
end
