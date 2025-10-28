# == Schema Information
#
# Table name: general_elections
#
#  id                                    :integer          not null, primary key
#  commons_library_briefing_url          :string(255)
#  electorate_population_count           :integer
#  invalid_vote_count                    :integer
#  is_notional                           :boolean          default(FALSE)
#  polling_on                            :date             not null
#  valid_vote_count                      :integer
#  general_election_publication_state_id :bigint
#  parliament_period_id                  :integer          not null
#
# Indexes
#
#  idx_on_general_election_publication_state_id_4f5de0080a  (general_election_publication_state_id)
#  index_general_elections_on_parliament_period_id          (parliament_period_id)
#
# Foreign Keys
#
#  fk_parliament_period  (parliament_period_id => parliament_periods.id)
#  fk_rails_...          (general_election_publication_state_id => general_election_publication_states.id)
#
class GeneralElection < ApplicationRecord
  
  belongs_to :parliament_period
  
  def display_label
    display_label = self.polling_on.strftime( '%Y  - %-d %B' )
  end
  
  def has_results?
    has_results = false
    has_results = true if self.valid_vote_count != 0
    has_results
  end
  
  def undecorated_elections
    Election.find_by_sql(
      "
        SELECT e.*
        FROM elections e
        WHERE e.general_election_id = #{self.id}
      "
    )
  end
  
  def elections
    Election.find_by_sql([
      "
        SELECT e.*, cg.name AS constituency_group_name, ca.geographic_code AS constituency_area_geographic_code, cg.constituency_area_id AS constituency_area_id, elec.population_count AS electorate_population_count
        FROM elections e, constituency_groups cg, constituency_areas ca, electorates elec
        WHERE e.general_election_id = ?
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND e.electorate_id = elec.id
        ORDER BY constituency_group_name
      ", id
    ])
  end
  
  def elections_in_country( country )
    Election.find_by_sql([
      "
        SELECT e.*, cg.name AS constituency_group_name, ca.geographic_code AS constituency_area_geographic_code, cg.constituency_area_id AS constituency_area_id, elec.population_count AS electorate_population_count
        FROM elections e, constituency_groups cg, constituency_areas ca, countries c, electorates elec
        WHERE e.general_election_id = :id
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND e.electorate_id = elec.id
        AND (
          (
            ca.country_id = c.id
            AND
            c.id = :country_id
          )
          
          OR (
            ca.country_id = c.id
            AND
            c.parent_country_id = :country_id
          )
        )
        ORDER BY cg.name
      ", id: id, country_id: country.id
    ])
  end
  
  def elections_in_english_region( english_region )
    Election.find_by_sql([
      "
        SELECT e.*, cg.name AS constituency_group_name
        FROM elections e, constituency_groups cg, constituency_areas ca
        WHERE e.general_election_id = :id
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.english_region_id = :english_region_id
        ORDER BY cg.name
      ", id: id, english_region_id: english_region.id
    ])
  end
  
  def elections_by_majority
    elections = self.elections_with_stats
  end
  
  def elections_by_vote_share
    elections = self.elections_with_stats
    elections.sort_by {|election| election.vote_share}.reverse!
  end
  
  def elections_by_turnout
    elections = self.elections_with_stats
    elections.sort_by {|election| election.turnout_percentage}.reverse!
  end
  
  def elections_by_declaration_time
    elections = self.elections_with_stats
    elections.sort_by {|election| election.declaration_at}
  end
  
  # A query to get all elections in a general election with stats for majority, vote share and turnout.
  def elections_with_stats
    Election.find_by_sql([
      "
        SELECT e.*,
          constituency_group.name AS constituency_group_name,
          constituency_area.geographic_code AS constituency_area_geographic_code,
          
          /* Return the winning candidacy information */
          winning_candidacy.candidate_given_name AS winning_candidacy_candidate_given_name,
          winning_candidacy.candidate_family_name AS winning_candidacy_candidate_family_name,
          winning_candidacy.is_standing_as_commons_speaker AS winning_candidacy_standing_as_commons_speaker,
          winning_candidacy.is_standing_as_independent AS winning_candidacy_standing_as_independent,
          winning_candidacy_party.party_id AS main_party_id,
          winning_candidacy_party.party_name AS main_party_name,
          winning_candidacy_party.party_abbreviation AS main_party_abbreviation,
          winning_candidacy_party.mnis_id AS main_party_mnis_id,
          winning_candidacy_adjunct_party.party_id AS adjunct_party_id,
          winning_candidacy_adjunct_party.party_name AS adjunct_party_name,
          winning_candidacy_adjunct_party.party_abbreviation AS adjunct_party_abbreviation,
          winning_candidacy_member.mnis_id AS winning_candidacy_mnis_id,
          
          /* Return the majority */
          ( cast(e.majority as decimal) / e.valid_vote_count ) AS majority_percentage,
          
          /* Return the turnout */
          electorate.population_count AS electorate_population_count,
          ( cast(e.valid_vote_count as decimal) / electorate.population_count ) AS turnout_percentage,
          
          /* Return the vote share */
          winning_candidacy.vote_share AS vote_share
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM electorates
        ) electorate
        ON electorate.id = e.electorate_id
        
        INNER JOIN (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        LEFT JOIN (
          SELECT *
          FROM constituency_areas
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
        
        LEFT JOIN (
          SELECT c.*
          FROM candidacies c
          WHERE c.is_winning_candidacy IS TRUE
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, m.mnis_id
          FROM candidacies c, members m
          WHERE c.is_winning_candidacy IS TRUE
          AND c.member_id = m.id
        ) winning_candidacy_member
        ON winning_candidacy_member.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, pp.id AS party_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation, pp.mnis_id AS mnis_id
          FROM candidacies c, certifications cert, political_parties pp
          WHERE cert.candidacy_id = c.id
          AND cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NULL
          AND c.is_winning_candidacy IS TRUE
        ) winning_candidacy_party
        ON winning_candidacy_party.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, pp.id AS party_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation
          FROM candidacies c, certifications cert, political_parties pp
          WHERE cert.candidacy_id = c.id
          AND cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NOT NULL
          AND c.is_winning_candidacy IS TRUE
        ) winning_candidacy_adjunct_party
        ON winning_candidacy_adjunct_party.election_id = e.id
      
        
        WHERE general_election_id = ?
        ORDER BY majority_percentage DESC
      ", id
    ])
  end

  def elections_by_majority_in_english_region( english_region )
    elections = self.elections_with_stats_in_english_region( english_region )
  end
  
  def elections_by_vote_share_in_english_region( english_region )
    elections = self.elections_with_stats_in_english_region( english_region )
    elections.sort_by {|election| election.vote_share}.reverse!
  end
  
  def elections_by_turnout_in_english_region( english_region )
    elections = self.elections_with_stats_in_english_region( english_region )
    elections.sort_by {|election| election.turnout_percentage}.reverse!
  end
  
  def elections_by_declaration_time_in_english_region( english_region )
    elections = self.elections_with_stats_in_english_region( english_region )
    elections.sort_by {|election| election.declaration_at}
  end
  
  # A query to get all elections in a general election in an English region with stats for majority, vote share and turnout.
  def elections_with_stats_in_english_region( english_region )
    Election.find_by_sql([
      "
        SELECT e.*,
          constituency_group.name AS constituency_group_name,
          constituency_group.constituency_area_geographic_code AS constituency_area_geographic_code,
          
          /* Return the winning candidacy information */
          winning_candidacy.candidate_given_name AS winning_candidacy_candidate_given_name,
          winning_candidacy.candidate_family_name AS winning_candidacy_candidate_family_name,
          winning_candidacy.is_standing_as_commons_speaker AS  winning_candidacy_standing_as_commons_speaker,
          winning_candidacy.is_standing_as_independent AS  winning_candidacy_standing_as_independent,
          winning_candidacy_party.party_id AS main_party_id,
          winning_candidacy_party.party_name AS main_party_name,
          winning_candidacy_party.party_abbreviation AS main_party_abbreviation,
          winning_candidacy_party.party_mnis_id AS main_party_mnis_id,
          winning_candidacy_adjunct_party.party_id AS adjunct_party_id,
          winning_candidacy_adjunct_party.party_name AS adjunct_party_name,
          winning_candidacy_adjunct_party.party_abbreviation AS adjunct_party_abbreviation,
          winning_candidacy_member.mnis_id AS winning_candidacy_mnis_id,
          
          /* Return the majority */
          ( cast(e.majority as decimal) / e.valid_vote_count ) AS majority_percentage,
          
          /* Return the turnout */
          electorate.population_count AS electorate_population_count,
          ( cast(e.valid_vote_count as decimal) / electorate.population_count ) AS turnout_percentage,
          
          /* Return the vote share */
          winning_candidacy.vote_share AS vote_share
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM electorates
        ) electorate
        ON electorate.id = e.electorate_id
        
        INNER JOIN (
          SELECT cg.*, ca.geographic_code AS constituency_area_geographic_code
          FROM constituency_groups cg, constituency_areas ca
          WHERE cg.constituency_area_id = ca.id
          AND ca.english_region_id = :english_region_id
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        LEFT JOIN (
          SELECT c.*
          FROM candidacies c
          WHERE c.is_winning_candidacy IS TRUE
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, m.mnis_id
          FROM candidacies c, members m
          WHERE c.is_winning_candidacy IS TRUE
          AND c.member_id = m.id
        ) winning_candidacy_member
        ON winning_candidacy_member.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, pp.id AS party_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation, pp.mnis_id AS party_mnis_id
          FROM candidacies c, certifications cert, political_parties pp
          WHERE cert.candidacy_id = c.id
          AND cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NULL
          AND c.is_winning_candidacy IS TRUE
        ) winning_candidacy_party
        ON winning_candidacy_party.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, pp.id AS party_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation
          FROM candidacies c, certifications cert, political_parties pp
          WHERE cert.candidacy_id = c.id
          AND cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NOT NULL
          AND c.is_winning_candidacy IS TRUE
        ) winning_candidacy_adjunct_party
        ON winning_candidacy_adjunct_party.election_id = e.id
      
        
        WHERE general_election_id = :general_election_id
        ORDER BY majority_percentage DESC
      ", general_election_id: id, english_region_id: english_region.id
    ])
  end
  
  def elections_by_majority_in_country( country )
    elections = self.elections_with_stats_in_country( country )
  end
  
  def elections_by_vote_share_in_country( country )
    elections = self.elections_with_stats_in_country( country )
    elections.sort_by {|election| election.vote_share}.reverse!
  end
  
  def elections_by_turnout_in_country( country )
    elections = self.elections_with_stats_in_country( country )
    elections.sort_by {|election| election.turnout_percentage}.reverse!
  end
  
  def elections_by_declaration_time_in_country( country )
    elections = self.elections_with_stats_in_country( country )
    elections.sort_by {|election| election.declaration_at}
  end
  
  # A query to get all elections in a general election in a country with stats for majority, vote share and turnout.
  def elections_with_stats_in_country( country )
    Election.find_by_sql([
      "
        SELECT e.*,
          constituency_group.name AS constituency_group_name,
          constituency_group.constituency_area_geographic_code AS constituency_area_geographic_code,
          
          /* Return the winning candidacy information */
          winning_candidacy.candidate_given_name AS winning_candidacy_candidate_given_name,
          winning_candidacy.candidate_family_name AS winning_candidacy_candidate_family_name,
          winning_candidacy.is_standing_as_commons_speaker AS  winning_candidacy_standing_as_commons_speaker,
          winning_candidacy.is_standing_as_independent AS  winning_candidacy_standing_as_independent,
          winning_candidacy_party.party_id AS main_party_id,
          winning_candidacy_party.party_name AS main_party_name,
          winning_candidacy_party.party_abbreviation AS main_party_abbreviation,
          winning_candidacy_party.party_mnis_id AS main_party_mnis_id,
          winning_candidacy_adjunct_party.party_id AS adjunct_party_id,
          winning_candidacy_adjunct_party.party_name AS adjunct_party_name,
          winning_candidacy_adjunct_party.party_abbreviation AS adjunct_party_abbreviation,
          winning_candidacy_member.mnis_id AS winning_candidacy_mnis_id,
          
          /* Return the majority */
          ( cast(e.majority as decimal) / e.valid_vote_count ) AS majority_percentage,
          
          /* Return the turnout */
          electorate.population_count AS electorate_population_count,
          ( cast(e.valid_vote_count as decimal) / electorate.population_count ) AS turnout_percentage,
          
          /* Return the vote share */
          winning_candidacy.vote_share AS vote_share
        FROM elections e
        
        INNER JOIN (
          SELECT *
          FROM electorates
        ) electorate
        ON electorate.id = e.electorate_id
        
        INNER JOIN (
          SELECT cg.*, ca.geographic_code AS constituency_area_geographic_code
          FROM constituency_groups cg, constituency_areas ca, countries c
          WHERE cg.constituency_area_id = ca.id
          AND ca.country_id = c.id
          AND (
            c.id = :country_id
            OR
            c.parent_country_id = :country_id
          )
        ) constituency_group
        ON constituency_group.id = e.constituency_group_id
        
        LEFT JOIN (
          SELECT c.*
          FROM candidacies c
          WHERE c.is_winning_candidacy IS TRUE
        ) winning_candidacy
        ON winning_candidacy.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, m.mnis_id
          FROM candidacies c, members m
          WHERE c.is_winning_candidacy IS TRUE
          AND c.member_id = m.id
        ) winning_candidacy_member
        ON winning_candidacy_member.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, pp.id AS party_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation, pp.mnis_id AS party_mnis_id
          FROM candidacies c, certifications cert, political_parties pp
          WHERE cert.candidacy_id = c.id
          AND cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NULL
          AND c.is_winning_candidacy IS TRUE
        ) winning_candidacy_party
        ON winning_candidacy_party.election_id = e.id
        
        LEFT JOIN (
          SELECT c.*, pp.id AS party_id, pp.name AS party_name, pp.abbreviation AS party_abbreviation
          FROM candidacies c, certifications cert, political_parties pp
          WHERE cert.candidacy_id = c.id
          AND cert.political_party_id = pp.id
          AND cert.adjunct_to_certification_id IS NOT NULL
          AND c.is_winning_candidacy IS TRUE
        ) winning_candidacy_adjunct_party
        ON winning_candidacy_adjunct_party.election_id = e.id
      
        
        WHERE general_election_id = :general_election_id
        ORDER BY majority_percentage DESC
      ", general_election_id: id, country_id: country.id
    ])
  end
  
  # Party performances for all of the UK.
  def party_performance
  
    # New query from Rachel removing the need for the general election party performance table.
    PoliticalParty.find_by_sql([
      "
        SELECT
        	-- Political party mnis id. Used to apply a class to the table, loading party colours.
        	ppy.mnis_id AS party_mnis_id,
	
        	-- Political party id. Used to make a link to the political party page.
        	ppy.id AS political_party_id,
	
        	-- Political party name.
        	ppy.name AS political_party_name,
	
        	-- Political party abbreviation.
        	ppy.abbreviation AS political_party_abbreviation,

        	-- Count of the number of elections contested by the party.
        	COUNT(elc.id) AS constituency_contested_count,
	
        	-- Cumulative votes for the party.
        	SUM(cnd.vote_count) AS cumulative_vote_count,
	
        	--vote share of political party by country (given at var)
        	(SUM(cnd.vote_count) * 100) / SUM(SUM(cnd.vote_count)) OVER w AS vote_share,
          
        	 -- Count of elections won by the political party.
        	 COALESCE(SUM(CAST(cnd.is_winning_candidacy AS INT)), NULL, 0) AS constituency_won_count --cast bool at int to give 0/1 and sum to give total won

        FROM elections elc

        INNER JOIN general_elections gel
        	on gel.id = elc.general_election_id
	
        INNER JOIN candidacies cnd
        	ON cnd.election_id = elc.id
	
        LEFT JOIN certifications crt
        	ON crt.candidacy_id = cnd.id
	
        LEFT JOIN political_parties ppy
        	ON ppy.id = crt.political_party_id
	
        WHERE gel.id = :general_election_id
        AND crt.adjunct_to_certification_id IS NULL
        
        GROUP BY ppy.id, ppy.name, gel.id
        
        WINDOW w AS (PARTITION BY gel.id)
        
        ORDER BY constituency_won_count DESC, cumulative_vote_count DESC
         " , general_election_id: id
    ])
  end
  
  def party_performance_in_country( country )
    
    # New query from Rachel removing the need for the country general election party performance table.
    PoliticalParty.find_by_sql([
      "
        SELECT cun.where_id AS country_id,

        		ppy.id AS political_party_id,
		
        		ppy.mnis_id AS party_mnis_id,
		
	
        	  ppy.name AS party_name,
	
        	-- Political party abbreviation.
        	ppy.abbreviation AS party_abbreviation,
	  
        	--count of number of elections by party
        	COUNT(elc.id) AS  constituency_contested_count,
	
          --cumulative votes for party by country (given at where)
        	SUM(cnd.vote_count) AS cumulative_vote_count, 
	
        	--vote share of political party by country (given at var)
        	(SUM(cnd.vote_count) * 100) / SUM(SUM(cnd.vote_count)) OVER w AS vote_share,
	
        	--count of winning candidacies by political party for country
        	COALESCE(SUM(CAST(cnd.is_winning_candidacy AS INT)), NULL, 0) AS constituency_won_count, --cast bool at int to give 0/1 and sum to give total won
	
        	--count of total votes for country (declared at where)
        	SUM(SUM(cnd.vote_count)) OVER w AS country_total_votes,
	
        	--try this
        	SUM(SUM(elc.valid_vote_count)) OVER w AS country_total_votes_alt


        FROM(

        SELECT 
        	CASE WHEN cun2.id IS NULL
        		THEN cun1.id
        	ELSE cun2.id END AS true_id, --join on here
        	cun1.id AS where_id, --use on where here
        	cun2.id AS level2_id --for reference of l2 here
	
        FROM countries cun1
        LEFT JOIN countries cun2
        	ON cun1.id = cun2.parent_country_id
        )cun

        INNER JOIN constituency_areas cta
        	ON country_id = cun.true_id

        INNER JOIN constituency_groups ctg        
        	ON ctg.constituency_area_id = cta.id
	
        INNER JOIN elections elc
        	ON elc.constituency_group_id = ctg.id

        INNER JOIN general_elections gel
        	ON gel.id = elc.general_election_id
	
        INNER JOIN candidacies cnd
        	ON cnd.election_id = elc.id
	
        LEFT JOIN certifications crt
        	ON crt.candidacy_id = cnd.id
	
        LEFT JOIN political_parties ppy
        	ON ppy.id = crt.political_party_id

        WHERE cun.where_id = :country_id
        AND gel.id = :id
        AND crt.adjunct_to_certification_id IS NULL
        GROUP BY cun.where_id, ppy.id, ppy.name, gel.id
        WINDOW w AS (PARTITION BY cun.where_id, gel.id)
        ORDER BY constituency_won_count DESC, cumulative_vote_count DESC
      ", id: id, country_id: country.id
    ])
  end
  
  def party_performance_in_english_region( english_region )
   
   # New query from Rachel removing the need for the country general election party performance table.
    PoliticalParty.find_by_sql([
      "
        SELECT
        	COUNT(elc.id) AS constituency_contested_count,
        	COALESCE(SUM(CAST(cnd.is_winning_candidacy AS INT)), NULL, 0) AS constituency_won_count,
        	SUM(cnd.vote_count) AS cumulative_vote_count,
        	ppy.id AS political_party_id,
        	ern.id AS english_region_id,
        	ppy.name AS party_name,
        	ppy.abbreviation AS party_abbreviation,
        	ppy.mnis_id AS party_mnis_id,
	
        	--vote share of political party by english region (given at var)
        	(SUM(cnd.vote_count) * 100) / SUM(SUM(cnd.vote_count)) OVER w AS vote_share
        FROM elections elc

        INNER JOIN general_elections gel
        	ON gel.id = elc.general_election_id
	
        INNER JOIN candidacies cnd
        	ON cnd.election_id = elc.id
	
        LEFT JOIN certifications crt
        	ON crt.candidacy_id = cnd.id
	
        LEFT JOIN political_parties ppy
        	ON ppy.id = crt.political_party_id
	
        ----groups and areas required to join countries in
        INNER JOIN constituency_groups ctg        
        	ON ctg.id = elc.constituency_group_id
	
        INNER JOIN constituency_areas cta
        	ON cta.id = ctg.constituency_area_id
	
        INNER JOIN english_regions ern
        	ON ern.id = cta.english_region_id

        WHERE crt.adjunct_to_certification_id IS NULL
        AND gel.id = :id
        AND ern.id = :english_region_id

        GROUP BY ppy.id, ern.id, ppy.name,
      	  ppy.abbreviation, ppy.mnis_id, gel.id
          WINDOW w AS (PARTITION BY ern.id, gel.id)
        ORDER BY constituency_won_count DESC, cumulative_vote_count DESC
      ", id: id, english_region_id: english_region.id
    ])
  end
  
  def preceding_general_election
    GeneralElection.find_by_sql([
      "
        SELECT ge.*
        FROM general_elections ge
        WHERE polling_on < ?
        ORDER BY polling_on DESC
      ", polling_on
    ]).first
  end
  
  def countries
    Country.find_by_sql([
      "
        SELECT c.*
        FROM countries c, constituency_areas ca, constituency_groups cg, elections e
        WHERE c.id = ca.country_id
        AND cg.constituency_area_id = ca.id
        AND e.constituency_group_id = cg.id
        AND e.general_election_id = ?
        GROUP BY c.id
        ORDER by c.name
      ", id
    ])
  end
  
  def top_level_countries_with_elections
    Country.find_by_sql([
      "
        SELECT c.*,
          direct_top_level_country.election_count AS direct_top_level_country_election_count,
          parent_top_level_country.election_count AS parent_top_level_country_election_count
          
        FROM countries c
        
        LEFT JOIN (
          SELECT c.*, count(e.id) AS election_count
          FROM countries c, constituency_areas ca, constituency_groups cg, elections e
          WHERE ca.country_id = c.id
          AND cg.constituency_area_id = ca.id
          AND e.constituency_group_id = cg.id
          AND e.general_election_id = ?
          GROUP BY c.id
        ) direct_top_level_country
        ON direct_top_level_country.id = c.id
        
        LEFT JOIN (
          SELECT c.*, count(e.id) AS election_count
          FROM countries c, countries cc, constituency_areas ca, constituency_groups cg, elections e
          WHERE cc.parent_country_id = c.id
          AND ca.country_id = cc.id
          AND cg.constituency_area_id = ca.id
          AND e.constituency_group_id = cg.id
          AND e.general_election_id = ?
          GROUP BY c.id
        ) parent_top_level_country
        ON parent_top_level_country.id = c.id
        
        WHERE c.parent_country_id IS NULL
        AND direct_top_level_country.election_count != 0 OR parent_top_level_country.election_count != 0
        
        GROUP BY c.id, direct_top_level_country.election_count, parent_top_level_country_election_count
        ORDER by c.name
      ", id, id
    ])
  end
  
  def child_countries_with_elections_in_country( country)
    Country.find_by_sql([
      "
        SELECT c.*
        FROM countries c, constituency_areas ca, constituency_groups cg, elections e
        WHERE c.parent_country_id = :country_id
        AND c.id = ca.country_id
        AND cg.constituency_area_id = ca.id
        AND e.constituency_group_id = cg.id
        AND e.general_election_id = :id
        GROUP BY c.id
        ORDER BY c.name
      ", id: id, country_id: country.id
    ])
  end
  
  def english_regions_in_country( country )
    EnglishRegion.find_by_sql([
      "
        SELECT er.*
        FROM english_regions er, constituency_areas ca, constituency_groups cg, elections e
        WHERE er.id = ca.english_region_id
        AND er.country_id = :country_id
        AND cg.constituency_area_id = ca.id
        AND e.constituency_group_id = cg.id
        AND e.general_election_id = :id
        GROUP BY er.id
        ORDER by er.name
      ", id: id, country_id: country.id
    ])
  end
  
  def elections_in_boundary_set( boundary_set )
    Election.find_by_sql([
      "
        SELECT e.*
        FROM elections e, constituency_groups cg, constituency_areas ca
        WHERE e.general_election_id = :id
        AND e.constituency_group_id = cg.id
        AND cg.constituency_area_id = ca.id
        AND ca.boundary_set_id = :boundary_set_id
      ", id: id, boundary_set_id: boundary_set.id
    ])
  end
  
  def previous_general_election
    GeneralElection.find_by_sql([
      "
        SELECT ge.*, count(e.*) AS election_count
        FROM general_elections ge, elections e
        WHERE ge.polling_on < ?
        AND e.general_election_id = ge.id
        AND e.is_notional IS FALSE
        GROUP BY ge.id
        ORDER BY polling_on DESC
      ", polling_on
    ]).first
  end
  
  def next_general_election
    GeneralElection.find_by_sql([
      "
        SELECT ge.*, count(e.*) AS election_count
        FROM general_elections ge, elections e
        WHERE ge.polling_on > ?
        AND e.general_election_id = ge.id
        AND e.is_notional IS FALSE
        GROUP BY ge.id
        ORDER BY polling_on
      ", polling_on
    ]).first
  end
  
  def uncertified_candidacies
    Candidacy.find_by_sql([
      "
        SELECT c.*,
          election.constituency_group_name AS constituency_group_name,
          constituency_area.geographic_code AS constituency_area_geographic_code,
          election.constituency_area_id AS constituency_area_id,
          member.mnis_id AS candidate_mnis_id,
          CASE
            WHEN is_standing_as_independent IS TRUE THEN 'Independent'
            WHEN is_standing_as_commons_speaker IS TRUE THEN 'Commons Speaker'
          END AS standing_as
        FROM candidacies c
        
        INNER JOIN (
          SELECT e.*, cg.name AS constituency_group_name, cg.constituency_area_id AS constituency_area_id
          FROM elections e, constituency_groups cg
          WHERE e.constituency_group_id = cg.id
          AND e.general_election_id = ?
        ) election
        ON election.id = c.election_id
        
        LEFT JOIN (
          SELECT *
          FROM constituency_areas
        ) constituency_area
        ON constituency_area.id = election.constituency_area_id
        
        LEFT JOIN (
          SELECT *
          FROM members
        ) member
        ON member.id = c.member_id
        
        WHERE ( c.is_standing_as_independent IS TRUE OR is_standing_as_commons_speaker IS TRUE )
        ORDER BY vote_count DESC
        
        
      ", id
    ])
  end
  
  def uncertified_candidacies_in_country( country )
    Candidacy.find_by_sql([
      "
        SELECT c.*,
          election.constituency_group_name AS constituency_group_name,
          election.constituency_area_geographic_code AS constituency_area_geographic_code,
          election.constituency_area_id AS constituency_area_id,
          member.mnis_id AS candidate_mnis_id,
          CASE
            WHEN is_standing_as_independent IS TRUE THEN 'Independent'
            WHEN is_standing_as_commons_speaker IS TRUE THEN 'Commons Speaker'
          END AS standing_as
        FROM candidacies c
        
        INNER JOIN (
          SELECT e.*, cg.name AS constituency_group_name, cg.constituency_area_id AS constituency_area_id, ca.geographic_code AS constituency_area_geographic_code
          FROM elections e, constituency_groups cg, constituency_areas ca, countries c
          WHERE e.constituency_group_id = cg.id
          AND e.general_election_id = :id
          AND cg.constituency_area_id = ca.id
          AND ca.country_id = c.id
          AND (
            c.id = :country_id
            OR
            c.parent_country_id = :country_id
          )
        ) election
        ON election.id = c.election_id
        
        LEFT JOIN (
          SELECT *
          FROM members
        ) member
        ON member.id = c.member_id
        
        WHERE ( c.is_standing_as_independent IS TRUE OR is_standing_as_commons_speaker IS TRUE )
        ORDER BY c.vote_count DESC
      ", id: id, country_id: country.id
    ])
  end
  
  def uncertified_candidacies_in_english_region( english_region )
    Candidacy.find_by_sql([
      "
        SELECT c.*,
          election.constituency_group_name AS constituency_group_name,
          election.constituency_area_geographic_code AS constituency_area_geographic_code,
          election.constituency_area_id AS constituency_area_id,
          member.mnis_id AS candidate_mnis_id,
          CASE
            WHEN is_standing_as_independent IS TRUE THEN 'Independent'
            WHEN is_standing_as_commons_speaker IS TRUE THEN 'Commons Speaker'
          END AS standing_as
        FROM candidacies c
        
        INNER JOIN (
          SELECT e.*, cg.name AS constituency_group_name, cg.constituency_area_id AS constituency_area_id, ca.geographic_code AS constituency_area_geographic_code
          FROM elections e, constituency_groups cg, constituency_areas ca
          WHERE e.constituency_group_id = cg.id
          AND e.general_election_id = :id
          AND cg.constituency_area_id = ca.id
          AND ca.english_region_id = :english_region_id
        ) election
        ON election.id = c.election_id
        
        LEFT JOIN (
          SELECT *
          FROM members
        ) member
        ON member.id = c.member_id
        
        WHERE ( c.is_standing_as_independent IS TRUE OR is_standing_as_commons_speaker IS TRUE )
        ORDER BY c.vote_count DESC
      ", id: id, english_region_id: english_region.id
    ])
  end
  
  def candidacies
    Candidacy.find_by_sql([
      "
        SELECT *,
          member.mnis_id AS member_mnis_id,
          election.parliament_period_number AS parliament_period_number,
          election.parliament_period_summoned_on AS parliament_period_summoned_on,
          election.parliament_period_state_opening_on AS parliament_period_state_opening_on,
          election.parliament_period_dissolved_on AS parliament_period_dissolved_on,
          election.parliament_period_commons_library_by_election_briefing_url AS parliament_period_commons_library_by_election_briefing_url,
          election.parliament_period_wikidata_id AS parliament_period_wikidata_id,
          election.parliament_period_id AS parliament_period_id,
          election.parliament_period_london_gazette AS parliament_period_london_gazette,
          election.general_election_polling_on AS general_election_polling_on,
          election.general_election_is_notional AS general_election_is_notional,
          election.general_election_commons_library_briefing_url AS general_election_commons_library_briefing_url,
          election.general_election_electorate_population_count AS general_election_electorate_population_count,
          election.general_election_valid_vote_count AS general_election_valid_vote_count,
          election.general_election_invalid_vote_count AS general_election_invalid_vote_count,
          election.general_election_id AS general_election_id,
          election.electorate_population_count AS electorate_population_count,
          constituency_group.name AS constituency_group_name,
          constituency_area.name AS constituency_area_name,
          constituency_area.geographic_code AS constituency_area_geographic_code,
          constituency_area.id AS constituency_area_id,
          constituency_area.area_type AS constituency_area_area_type,
          constituency_area.country_name AS constituency_area_country_name,
          constituency_area.country_geographic_code AS constituency_area_country_geographic_code,
          constituency_area.country_id AS constituency_area_country_id,
          constituency_area.boundary_set_start_on AS boundary_set_start_on,
          constituency_area.boundary_set_end_on AS boundary_set_end_on,
          constituency_area.boundary_set_id AS boundary_set_id,
          english_region.name AS english_region_name,
          english_region.geographic_code AS english_region_geographic_code,
          english_region.id AS english_region_id,
          result_summary.summary AS result_summary_summary,
          result_summary.short_summary AS result_summary_short_summary,
          election.polling_on AS election_polling_on,
          
          CASE 
            WHEN election.general_election_id IS NULL
              THEN TRUE
              ELSE FALSE
          END AS election_is_by_election,
          
          election.is_notional AS election_is_notional,
          election.valid_vote_count AS election_valid_vote_count,
          election.invalid_vote_count AS election_invalid_vote_count,
          election.majority AS election_majority,
          election.declaration_at AS election_declaration_at,
          main_party.name AS main_party_name,
          main_party.abbreviation AS main_party_abbreviation,
          main_party.mnis_id AS main_party_mnis_id,
          main_party.id AS main_party_id,
          adjunct_party.name AS adjunct_party_name,
          adjunct_party.abbreviation AS adjunct_party_abbreviation,
          adjunct_party.mnis_id AS adjunct_party_mnis_id
        FROM candidacies cand
        
        LEFT JOIN (
          SELECT *
          FROM members
        ) member
        ON member.id = cand.member_id
        
        INNER JOIN (
          SELECT e.*,
            pp.number AS parliament_period_number,
            pp.summoned_on AS parliament_period_summoned_on,
            pp.state_opening_on AS parliament_period_state_opening_on,
            pp.dissolved_on AS parliament_period_dissolved_on,
            pp.commons_library_briefing_by_election_briefing_url AS parliament_period_commons_library_by_election_briefing_url,
            pp.wikidata_id AS parliament_period_wikidata_id,
            pp.london_gazette AS parliament_period_london_gazette,
            ge.polling_on AS general_election_polling_on,
            ge.is_notional AS general_election_is_notional,
            ge.commons_library_briefing_url AS general_election_commons_library_briefing_url,
            ge.electorate_population_count AS general_election_electorate_population_count,
            ge.valid_vote_count AS general_election_valid_vote_count,
            ge.invalid_vote_count AS general_election_invalid_vote_count,
            el.population_count AS electorate_population_count
          FROM elections e, general_elections ge, parliament_periods pp, electorates el
          WHERE e.general_election_id = ge.id
          AND ge.id = ?
          AND e.parliament_period_id = pp.id
          AND e.electorate_id = el.id
          
        ) election
        ON election.id = cand.election_id
        
        LEFT JOIN (
          SELECT *
          FROM result_summaries
        ) result_summary
        ON election.result_summary_id = result_summary.id
        
        INNER JOIN (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = election.constituency_group_id
        
        LEFT JOIN (
          SELECT ca.*,
            cat.area_type AS area_type,
            co.name AS country_name,
            co.geographic_code AS country_geographic_code,
            bs.start_on AS boundary_set_start_on,
            bs.end_on AS boundary_set_end_on
          FROM constituency_areas ca, constituency_area_types cat, countries co, boundary_sets bs
          WHERE ca.constituency_area_type_id = cat.id
          AND ca.country_id = co.id
          AND ca.boundary_set_id = bs.id
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
        
        LEFT JOIN (
          SELECT *
          FROM english_regions
        ) english_region
        ON english_region.id = constituency_area.english_region_id
        
        LEFT JOIN (
          SELECT cert.candidacy_id, pp.*
          FROM political_parties pp, certifications cert
          WHERE pp.id = cert.political_party_id
          AND cert.adjunct_to_certification_id IS NULL
        ) main_party
        ON main_party.candidacy_id = cand.id
        
        LEFT JOIN (
          SELECT cert.candidacy_id, pp.*
          FROM political_parties pp, certifications cert
          WHERE pp.id = cert.political_party_id
          AND cert.adjunct_to_certification_id IS NOT NULL
        ) adjunct_party
        ON adjunct_party.candidacy_id = cand.id
        
        ORDER BY constituency_area_name, result_position
        
      ", id
    ])
  end
  
  def candidacies_in_country( country )
    Candidacy.find_by_sql([
      "
        SELECT *,
          member.mnis_id AS member_mnis_id,
          election.parliament_period_number AS parliament_period_number,
          election.parliament_period_summoned_on AS parliament_period_summoned_on,
          election.parliament_period_state_opening_on AS parliament_period_state_opening_on,
          election.parliament_period_dissolved_on AS parliament_period_dissolved_on,
          election.parliament_period_commons_library_by_election_briefing_url AS parliament_period_commons_library_by_election_briefing_url,
          election.parliament_period_wikidata_id AS parliament_period_wikidata_id,
          election.parliament_period_id AS parliament_period_id,
          election.parliament_period_london_gazette AS parliament_period_london_gazette,
          election.general_election_polling_on AS general_election_polling_on,
          election.general_election_is_notional AS general_election_is_notional,
          election.general_election_commons_library_briefing_url AS general_election_commons_library_briefing_url,
          election.general_election_electorate_population_count AS general_election_electorate_population_count,
          election.general_election_valid_vote_count AS general_election_valid_vote_count,
          election.general_election_invalid_vote_count AS general_election_invalid_vote_count,
          election.general_election_id AS general_election_id,
          election.electorate_population_count AS electorate_population_count,
          constituency_group.name AS constituency_group_name,
          constituency_area.name AS constituency_area_name,
          constituency_area.geographic_code AS constituency_area_geographic_code,
          constituency_area.id AS constituency_area_id,
          constituency_area.area_type AS constituency_area_area_type,
          constituency_area.country_name AS constituency_area_country_name,
          constituency_area.country_geographic_code AS constituency_area_country_geographic_code,
          constituency_area.country_id AS constituency_area_country_id,
          constituency_area.boundary_set_start_on AS boundary_set_start_on,
          constituency_area.boundary_set_end_on AS boundary_set_end_on,
          constituency_area.boundary_set_id AS boundary_set_id,
          english_region.name AS english_region_name,
          english_region.geographic_code AS english_region_geographic_code,
          english_region.id AS english_region_id,
          result_summary.summary AS result_summary_summary,
          result_summary.short_summary AS result_summary_short_summary,
          election.polling_on AS election_polling_on,
          
          CASE 
            WHEN election.general_election_id IS NULL
              THEN TRUE
              ELSE FALSE
          END AS election_is_by_election,
          
          election.is_notional AS election_is_notional,
          election.valid_vote_count AS election_valid_vote_count,
          election.invalid_vote_count AS election_invalid_vote_count,
          election.majority AS election_majority,
          election.declaration_at AS election_declaration_at,
          main_party.name AS main_party_name,
          main_party.abbreviation AS main_party_abbreviation,
          main_party.mnis_id AS main_party_mnis_id,
          main_party.id AS main_party_id,
          adjunct_party.name AS adjunct_party_name,
          adjunct_party.abbreviation AS adjunct_party_abbreviation,
          adjunct_party.mnis_id AS adjunct_party_mnis_id
        FROM candidacies cand
        
        LEFT JOIN (
          SELECT *
          FROM members
        ) member
        ON member.id = cand.member_id
        
        INNER JOIN (
          SELECT e.*,
            pp.number AS parliament_period_number,
            pp.summoned_on AS parliament_period_summoned_on,
            pp.state_opening_on AS parliament_period_state_opening_on,
            pp.dissolved_on AS parliament_period_dissolved_on,
            pp.commons_library_briefing_by_election_briefing_url AS parliament_period_commons_library_by_election_briefing_url,
            pp.wikidata_id AS parliament_period_wikidata_id,
            pp.london_gazette AS parliament_period_london_gazette,
            ge.polling_on AS general_election_polling_on,
            ge.is_notional AS general_election_is_notional,
            ge.commons_library_briefing_url AS general_election_commons_library_briefing_url,
            ge.electorate_population_count AS general_election_electorate_population_count,
            ge.valid_vote_count AS general_election_valid_vote_count,
            ge.invalid_vote_count AS general_election_invalid_vote_count,
            el.population_count AS electorate_population_count
          FROM elections e, general_elections ge, parliament_periods pp, electorates el
          WHERE e.general_election_id = ge.id
          AND ge.id = :id
          AND e.parliament_period_id = pp.id
          AND e.electorate_id = el.id
          
        ) election
        ON election.id = cand.election_id
        
        LEFT JOIN (
          SELECT *
          FROM result_summaries
        ) result_summary
        ON election.result_summary_id = result_summary.id
        
        INNER JOIN (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = election.constituency_group_id
        
        INNER JOIN (
          SELECT ca.*,
            cat.area_type AS area_type,
            co.name AS country_name,
            co.geographic_code AS country_geographic_code,
            bs.start_on AS boundary_set_start_on,
            bs.end_on AS boundary_set_end_on
          FROM constituency_areas ca, constituency_area_types cat, countries co, boundary_sets bs
          WHERE ca.constituency_area_type_id = cat.id
          AND ca.country_id = co.id
          AND ca.boundary_set_id = bs.id
          AND (
           co.id = :country_id
           OR
           co.parent_country_id = :country_id
          )
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
        
        LEFT JOIN (
          SELECT *
          FROM english_regions
        ) english_region
        ON english_region.id = constituency_area.english_region_id
        
        LEFT JOIN (
          SELECT cert.candidacy_id, pp.*
          FROM political_parties pp, certifications cert
          WHERE pp.id = cert.political_party_id
          AND cert.adjunct_to_certification_id IS NULL
        ) main_party
        ON main_party.candidacy_id = cand.id
        
        LEFT JOIN (
          SELECT cert.candidacy_id, pp.*
          FROM political_parties pp, certifications cert
          WHERE pp.id = cert.political_party_id
          AND cert.adjunct_to_certification_id IS NOT NULL
        ) adjunct_party
        ON adjunct_party.candidacy_id = cand.id
        
        ORDER BY constituency_area_name, result_position
        
      ", id: id, country_id: country.id
    ])
  end
  
  def candidacies_in_english_region( english_region )
    Candidacy.find_by_sql([
      "
        SELECT *,
          member.mnis_id AS member_mnis_id,
          election.parliament_period_number AS parliament_period_number,
          election.parliament_period_summoned_on AS parliament_period_summoned_on,
          election.parliament_period_state_opening_on AS parliament_period_state_opening_on,
          election.parliament_period_dissolved_on AS parliament_period_dissolved_on,
          election.parliament_period_commons_library_by_election_briefing_url AS parliament_period_commons_library_by_election_briefing_url,
          election.parliament_period_wikidata_id AS parliament_period_wikidata_id,
          election.parliament_period_id AS parliament_period_id,
          election.parliament_period_london_gazette AS parliament_period_london_gazette,
          election.general_election_polling_on AS general_election_polling_on,
          election.general_election_is_notional AS general_election_is_notional,
          election.general_election_commons_library_briefing_url AS general_election_commons_library_briefing_url,
          election.general_election_electorate_population_count AS general_election_electorate_population_count,
          election.general_election_valid_vote_count AS general_election_valid_vote_count,
          election.general_election_invalid_vote_count AS general_election_invalid_vote_count,
          election.general_election_id AS general_election_id,
          election.electorate_population_count AS electorate_population_count,
          constituency_group.name AS constituency_group_name,
          constituency_area.name AS constituency_area_name,
          constituency_area.geographic_code AS constituency_area_geographic_code,
          constituency_area.id AS constituency_area_id,
          constituency_area.area_type AS constituency_area_area_type,
          constituency_area.country_name AS constituency_area_country_name,
          constituency_area.country_geographic_code AS constituency_area_country_geographic_code,
          constituency_area.country_id AS constituency_area_country_id,
          constituency_area.boundary_set_start_on AS boundary_set_start_on,
          constituency_area.boundary_set_end_on AS boundary_set_end_on,
          constituency_area.boundary_set_id AS boundary_set_id,
          english_region.name AS english_region_name,
          english_region.geographic_code AS english_region_geographic_code,
          english_region.id AS english_region_id,
          result_summary.summary AS result_summary_summary,
          result_summary.short_summary AS result_summary_short_summary,
          election.polling_on AS election_polling_on,
          
          CASE 
            WHEN election.general_election_id IS NULL
              THEN TRUE
              ELSE FALSE
          END AS election_is_by_election,
          
          election.is_notional AS election_is_notional,
          election.valid_vote_count AS election_valid_vote_count,
          election.invalid_vote_count AS election_invalid_vote_count,
          election.majority AS election_majority,
          election.declaration_at AS election_declaration_at,
          main_party.name AS main_party_name,
          main_party.abbreviation AS main_party_abbreviation,
          main_party.mnis_id AS main_party_mnis_id,
          main_party.id AS main_party_id,
          adjunct_party.name AS adjunct_party_name,
          adjunct_party.abbreviation AS adjunct_party_abbreviation,
          adjunct_party.mnis_id AS adjunct_party_mnis_id
        FROM candidacies cand
        
        LEFT JOIN (
          SELECT *
          FROM members
        ) member
        ON member.id = cand.member_id
        
        INNER JOIN (
          SELECT e.*,
            pp.number AS parliament_period_number,
            pp.summoned_on AS parliament_period_summoned_on,
            pp.state_opening_on AS parliament_period_state_opening_on,
            pp.dissolved_on AS parliament_period_dissolved_on,
            pp.commons_library_briefing_by_election_briefing_url AS parliament_period_commons_library_by_election_briefing_url,
            pp.wikidata_id AS parliament_period_wikidata_id,
            pp.london_gazette AS parliament_period_london_gazette,
            ge.polling_on AS general_election_polling_on,
            ge.is_notional AS general_election_is_notional,
            ge.commons_library_briefing_url AS general_election_commons_library_briefing_url,
            ge.electorate_population_count AS general_election_electorate_population_count,
            ge.valid_vote_count AS general_election_valid_vote_count,
            ge.invalid_vote_count AS general_election_invalid_vote_count,
            el.population_count AS electorate_population_count
          FROM elections e, general_elections ge, parliament_periods pp, electorates el
          WHERE e.general_election_id = ge.id
          AND ge.id = :id
          AND e.parliament_period_id = pp.id
          AND e.electorate_id = el.id
          
        ) election
        ON election.id = cand.election_id
        
        LEFT JOIN (
          SELECT *
          FROM result_summaries
        ) result_summary
        ON election.result_summary_id = result_summary.id
        
        INNER JOIN (
          SELECT *
          FROM constituency_groups
        ) constituency_group
        ON constituency_group.id = election.constituency_group_id
        
        INNER JOIN (
          SELECT ca.*,
            cat.area_type AS area_type,
            co.name AS country_name,
            co.geographic_code AS country_geographic_code,
            bs.start_on AS boundary_set_start_on,
            bs.end_on AS boundary_set_end_on
          FROM constituency_areas ca, constituency_area_types cat, countries co, boundary_sets bs
          WHERE ca.constituency_area_type_id = cat.id
          AND ca.english_region_id = :english_region_id
          AND ca.country_id = co.id
          AND ca.boundary_set_id = bs.id
        ) constituency_area
        ON constituency_area.id = constituency_group.constituency_area_id
        
        LEFT JOIN (
          SELECT *
          FROM english_regions
        ) english_region
        ON english_region.id = constituency_area.english_region_id
        
        LEFT JOIN (
          SELECT cert.candidacy_id, pp.*
          FROM political_parties pp, certifications cert
          WHERE pp.id = cert.political_party_id
          AND cert.adjunct_to_certification_id IS NULL
        ) main_party
        ON main_party.candidacy_id = cand.id
        
        LEFT JOIN (
          SELECT cert.candidacy_id, pp.*
          FROM political_parties pp, certifications cert
          WHERE pp.id = cert.political_party_id
          AND cert.adjunct_to_certification_id IS NOT NULL
        ) adjunct_party
        ON adjunct_party.candidacy_id = cand.id
        
        ORDER BY constituency_area_name, result_position
        
      ", id: id, english_region_id: english_region.id
    ])
  end
  
  def boundary_sets
    BoundarySet.find_by_sql([
      "
        SELECT bs.*, c.name AS country_name, geibs.ordinality
        FROM boundary_sets bs, general_election_in_boundary_sets geibs, countries c
        WHERE geibs.general_election_id = ?
        AND geibs.boundary_set_id = bs.id
        AND bs.country_id = c.id
        ORDER BY country_name
      ", id
    ])
  end
  
  def countries_having_first_elections_in_boundary_set
    Country.find_by_sql([
      "
        SELECT c.*
        FROM countries c, boundary_sets bs, general_election_in_boundary_sets gebs
        WHERE c.id = bs.country_id
        AND bs.id = gebs.boundary_set_id
        AND gebs.general_election_id = ?
        AND gebs.ordinality = 1
        ORDER BY c.name
      ", id
    ])
  end
  
  def is_first_general_election_in_england_in_new_boundary_set?
    
    # We check if the countries having first elections in boundary set contains a country with ID 2 - England.
    self.countries_having_first_elections_in_boundary_set.any? {|country| country.id == 2 }
  end
  
  # A method to determine if this general election is the first held on a new boundary set for a country, or a child country of a country
  def first_general_election_in_boundary_set_in_country( country )
    first_general_election_in_boundary_set_in_country = false
    first = GeneralElectionInBoundarySet.find_by_sql([
      "
        SELECT gebs.*
        FROM general_election_in_boundary_sets gebs, boundary_sets bs, countries c
        WHERE gebs.general_election_id = :id
        AND gebs.ordinality = 1
        AND gebs.boundary_set_id = bs.id
        AND bs.country_id = c.id
        AND (
          c.id = :country_id
          OR
          c.parent_country_id = :country_id /* to cope with Great Britain */
        )
      ", id: id, country_id: country.id
    ])
    first_general_election_in_boundary_set_in_country = true unless first.empty?
    first_general_election_in_boundary_set_in_country
  end
  
  # Used to generate the breadcrumb label.
  def crumb_label
    crumb_label = self.polling_on.strftime( $CRUMB_DATE_DISPLAY_FORMAT )
    crumb_label += ' '
    crumb_label += self.general_election_type.downcase
    crumb_label
  end
  
  # Used to return the type of a general election, being either a general election or a notional general election.
  def general_election_type
    general_election_type = ''
    if self.is_notional
      general_election_type += 'Notional general election'
    else
      general_election_type += 'General election'
    end
    general_election_type
  end
  
  # Used to return the noun phrase article being 'the' for a real general election and 'an' for a notional general election.
  def noun_phrase_article
    noun_phrase_article = 'the'
    noun_phrase_article = 'a' if self.is_notional
    noun_phrase_article
  end
  
  # Used to return the result type.
  # Used by titles and descriptions.
  def result_type
    result_type = ''
    if self.is_notional
      result_type += 'Notional results'
    else
      result_type += 'Results'
    end
    result_type
  end
  
  def parliament_period_crumb_label
    parliament_period_crumb_label = self.parliament_period_number.ordinalize
    parliament_period_crumb_label += ' Parliament'
  end
  
  def csv_filename
    csv_filename = 'candidate-level-results-'
    csv_filename += 'notional-' if self.is_notional
    csv_filename += 'general-election-'
    csv_filename += self.polling_on.strftime( '%d-%m-%Y' )
    csv_filename += '.csv'
    csv_filename
  end
  
  def csv_filename_for_country( country )
    csv_filename = 'candidate-level-results-in-'
    csv_filename += country.name.downcase.gsub( ' ', '-' ) + '-'
    csv_filename += 'notional-' if self.is_notional
    csv_filename += 'general-election-'
    csv_filename += self.polling_on.strftime( '%d-%m-%Y' )
    csv_filename += '.csv'
    csv_filename
  end
  
  def csv_filename_for_english_region( english_region )
    csv_filename = 'candidate-level-results-in-england-'
    csv_filename += english_region.name.downcase.gsub( ' ', '-' ) + '-'
    csv_filename += 'notional-' if self.is_notional
    csv_filename += 'general-election-'
    csv_filename += self.polling_on.strftime( '%d-%m-%Y' )
    csv_filename += '.csv'
    csv_filename
  end
end
