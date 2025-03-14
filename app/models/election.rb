# == Schema Information
#
# Table name: elections
#
#  id                    :integer          not null, primary key
#  declaration_at        :datetime
#  invalid_vote_count    :integer
#  is_notional           :boolean          default(FALSE)
#  majority              :integer
#  polling_on            :date             not null
#  valid_vote_count      :integer
#  writ_issued_on        :date
#  constituency_group_id :integer          not null
#  electorate_id         :integer
#  general_election_id   :integer
#  parliament_period_id  :integer          not null
#  result_summary_id     :integer
#
# Indexes
#
#  index_elections_on_constituency_group_id  (constituency_group_id)
#  index_elections_on_electorate_id          (electorate_id)
#  index_elections_on_general_election_id    (general_election_id)
#  index_elections_on_parliament_period_id   (parliament_period_id)
#  index_elections_on_result_summary_id      (result_summary_id)
#
# Foreign Keys
#
#  fk_constituency_group  (constituency_group_id => constituency_groups.id)
#  fk_electorate          (electorate_id => electorates.id)
#  fk_general_election    (general_election_id => general_elections.id)
#  fk_parliament_period   (parliament_period_id => parliament_periods.id)
#  fk_rails_...           (general_election_id => general_elections.id) ON DELETE => cascade
#  fk_result_summary      (result_summary_id => result_summaries.id)
#
class Election < ApplicationRecord
  
  belongs_to :constituency_group
  belongs_to :electorate, optional: true
  belongs_to :general_election, optional: true
  belongs_to :result_summary, optional: true
  belongs_to :parliament_period
  
  def list_name
    self.polling_on.strftime( $DATE_DISPLAY_FORMAT ) + ' - ' + self.constituency_name
  end
  
  def winning_candidacy
    Candidacy.all.where( "election_id = ?", self ).where( 'is_winning_candidacy IS TRUE' ).first
  end
  
  def by_election_display_title
    display_title = self.constituency_group_name
    display_title += ' - ' + self.polling_on.strftime( $DATE_DISPLAY_FORMAT )
    display_title
  end
  
  def candidacies
    Candidacy.find_by_sql([
      "
        SELECT c.*,
          member.mnis_id AS member_mnis_id, 
          main_party.id AS main_party_id, 
          main_party.name AS main_party_name,
          main_party.abbreviation AS main_party_abbreviation,
          main_party.mnis_id AS main_party_mnis_id,
          adjunct_party.id AS adjunct_party_id, 
          adjunct_party.name AS adjunct_party_name,
          adjunct_party.abbreviation AS adjunct_party_abbreviation
        FROM candidacies c
        
        LEFT JOIN (
          SELECT *
          FROM members
        ) member
        ON member.id = c.member_id
        
        LEFT JOIN (
          SELECT pp.*, c.candidacy_id AS candidacy_id
          FROM political_parties pp, certifications c
          WHERE c.political_party_id = pp.id
          AND c.adjunct_to_certification_id IS NULL
        ) main_party
        ON main_party.candidacy_id = c.id
        
        LEFT JOIN (
          SELECT pp.*, c.candidacy_id AS candidacy_id
          FROM political_parties pp, certifications c
          WHERE c.political_party_id = pp.id
          AND c.adjunct_to_certification_id IS NOT NULL
        ) adjunct_party
        ON adjunct_party.candidacy_id = c.id
        
        WHERE c.election_id = ?
        ORDER BY c.candidate_family_name, c.candidate_given_name
      ", id
    ])
  end
  
  def results
    Candidacy.find_by_sql([
      "
        SELECT c.*,
          member.mnis_id AS member_mnis_id, 
          main_party.id AS main_party_id, 
          main_party.name AS main_party_name,
          main_party.abbreviation AS main_party_abbreviation,
          main_party.mnis_id AS main_party_mnis_id,
          adjunct_party.id AS adjunct_party_id, 
          adjunct_party.name AS adjunct_party_name,
          adjunct_party.abbreviation AS adjunct_party_abbreviation
        FROM candidacies c
        
        LEFT JOIN (
          SELECT *
          FROM members
        ) member
        ON member.id = c.member_id
        
        LEFT JOIN (
          SELECT pp.*, c.candidacy_id AS candidacy_id
          FROM political_parties pp, certifications c
          WHERE c.political_party_id = pp.id
          AND c.adjunct_to_certification_id IS NULL
        ) main_party
        ON main_party.candidacy_id = c.id
        
        LEFT JOIN (
          SELECT pp.*, c.candidacy_id AS candidacy_id
          FROM political_parties pp, certifications c
          WHERE c.political_party_id = pp.id
          AND c.adjunct_to_certification_id IS NOT NULL
        ) adjunct_party
        ON adjunct_party.candidacy_id = c.id
        
        WHERE c.election_id = ?
        ORDER BY c.vote_count desc
      ", id
    ])
  end
  
  # ## A method to determine if an election has been held.
  def has_been_held?
    
    # We base this logic on whether the election has a valid vote count.
    has_been_held = false
    has_been_held = true if self.valid_vote_count
    has_been_held
  end
  
  def winning_candidate_name
    self.winning_candidate_given_name + ' ' + self.winning_candidate_family_name 
  end
  
  def turnout
    turnout = self.valid_vote_count.to_f / self.electorate_population_count.to_f
    turnout = turnout * 100
    turnout = turnout.round( 1 )
  end
  
  def candidate_polling_name
    candidate_polling_name = self.winning_candidacy_candidate_family_name.upcase
    candidate_polling_name += ', '
    candidate_polling_name += self.winning_candidacy_candidate_given_name
    candidate_polling_name
  end
  
  def political_party_candidacy( political_party )
    Candidacy.find_by_sql([
      "
        SELECT can.* 
        FROM candidacies can, certifications cert
        WHERE can.election_id = ?
        AND can.id = cert.candidacy_id
        AND cert.political_party_id = #{political_party.id}
        ORDER BY can.vote_count DESC
      ", id
    ]).first
  end
  
  def winning_candidacy_party_names
    winning_candidacy_party_names = self.winning_candidacy_party_name
    winning_candidacy_party_names += ' / ' + self.winning_candidacy_adjunct_party_name if self.winning_candidacy_adjunct_party_name
    winning_candidacy_party_names
  end
  
  def boundary_set
    BoundarySet.find_by_sql([
      "
        SELECT bs.*
        FROM boundary_sets bs, constituency_areas ca, constituency_groups cg, elections e
        WHERE bs.id = ca.boundary_set_id
        AND cg.constituency_area_id = ca.id
        AND cg.id = e.constituency_group_id
        AND e.id = ?
      ", id
    ]).first
  end
  
  def previous_election
    Election.find_by_sql([
      "
        SELECT e.*
        FROM elections e
        WHERE e.constituency_group_id = :constituency_group_id
        AND e.polling_on < :polling_on
        AND e.is_notional IS FALSE
        ORDER BY e.polling_on DESC
      ", constituency_group_id: constituency_group_id, polling_on: polling_on
    ]).first
  end
  
  def next_election
    Election.find_by_sql([
      "
        SELECT e.*
        FROM elections e
        WHERE e.constituency_group_id = :constituency_group_id
        AND e.polling_on > :polling_on
        AND e.is_notional IS FALSE
        ORDER BY e.polling_on
      ", constituency_group_id: constituency_group_id, polling_on: polling_on
    ]).first
  end
  
  def lost_deposit?
    lost_deposit = false
    if ( self.candidacy_vote_share.to_f * 100 ).round( 1 ) < 5
      lost_deposit = true
    end
    lost_deposit
  end
  
  def lost_deposit_text
    lost_deposit_text = 'No'
    if self.lost_deposit?
      lost_deposit_text = 'Yes'
    end
    lost_deposit_text
  end
  
  def main_party_class
    main_party_class = 'party'
    if self.main_party_mnis_id
      main_party_class += ' party-' + self.main_party_mnis_id.to_s
    end
    main_party_class
  end
  
  def legacy_url
    "https://electionresults.parliament.uk/election/#{self.polling_on}/Results/Location/Constituency/#{self.constituency_group_name.gsub( ' ', '%20' )}"
  end
  
  def boundary_set_having_first_general_election
    BoundarySet.find_by_sql([
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, general_election_in_boundary_sets geibs, general_elections ge, elections e, constituency_groups cg, constituency_areas ca, countries c
        WHERE bs.id = geibs.boundary_set_id
        AND geibs.ordinality = 1
        AND geibs.general_election_id = ge.id
        AND e.general_election_id = ge.id
        AND e.constituency_group_id = cg.id
        AND e.id = ?
        AND cg.constituency_area_id = ca.id
        AND ca.boundary_set_id = bs.id
        AND bs.country_id = c.id
      ", id
    ]).first
  end
  
  def election_in_constituency_area_label
    election_in_constituency_area_label = self.polling_on.strftime( $DATE_DISPLAY_FORMAT )
    election_in_constituency_area_label += ' - ' 
    election_in_constituency_area_label += 'general election' if self.general_election_id
    election_in_constituency_area_label += 'by-election' unless self.general_election_id
    election_in_constituency_area_label
  end
  
  def parliament_period_heading
    parliament_period_heading = "#{self.parliament_period_number.ordinalize} Parliament (#{self.parliament_period_summoned_on.strftime( $DATE_DISPLAY_FORMAT )} -"
    parliament_period_heading += " #{self.parliament_period_dissolved_on.strftime( $DATE_DISPLAY_FORMAT )}" if self.parliament_period_dissolved_on
    parliament_period_heading += ")"
    parliament_period_heading
  end
  
  def election_type
    election_type = ''
    if self.is_notional
      election_type = 'Notional election'
    elsif self.general_election_id
      election_type = 'Election'
    else
      election_type = 'By-election'
    end
    election_type
  end
  
  def by_election_label
    by_election_label = self.polling_on.strftime( $CRUMB_DATE_DISPLAY_FORMAT )
    by_election_label += ' - '
    by_election_label += self.constituency_group_name
  end
  
  def description
    description = self.election_type
    description += ' for the constituency of '
    description += self.constituency_group_name
    if self.general_election_id && !self.is_notional
      description += ' held as part of the general election'
    end
    description += " on #{self.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
    description
  end
  
  def parliament_period_crumb_label
    parliament_period_crumb_label = self.parliament_period_number.ordinalize
    parliament_period_crumb_label += ' Parliament'
  end
end
