COPY (
	SELECT
		constituency.geographic_code AS "ONS code",
		constituency.name AS "Constituency name",
		cand.candidate_family_name AS "Family name",
		cand.candidate_given_name AS "Given name",
		cand.democracy_club_person_identifier AS "Democracy Club identifier",
		member.mnis_id AS "Member MNIS ID",
		result_summary.short_summary AS "Result summary"
	
	FROM candidacies cand

	INNER JOIN (
		SELECT *
		FROM elections
		WHERE general_election_id = 6
	) election
	ON election.id = cand.election_id

	INNER JOIN (
		SELECT cg.*, ca.geographic_code
		FROM constituency_groups cg, constituency_areas ca
		WHERE cg.constituency_area_id = ca.id
	) constituency
	ON constituency.id = election.constituency_group_id
	
	INNER JOIN (
		SELECT * 
		FROM result_summaries
	) result_summary
	ON result_summary.id = election.result_summary_id

	LEFT JOIN (
		SELECT *
		FROM members
	) member
	ON member.id = cand.member_id

	WHERE cand.is_winning_candidacy IS TRUE
)
TO '/Users/smethurstm/Documents/code/rails/psephology/db/data/results-by-parliament/59/publication-state-tests/winners/winners.csv' DELIMITER ',' CSV HEADER;