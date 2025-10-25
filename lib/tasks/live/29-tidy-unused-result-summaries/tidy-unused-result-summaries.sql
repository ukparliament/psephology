DELETE FROM result_summaries WHERE id=58;
DELETE FROM result_summaries WHERE id=59;

/*
SELECT rs.id, election.count
FROM result_summaries rs
LEFT JOIN (
	SELECT result_summary_id, count(id) AS count
	FROM elections
	GROUP BY result_summary_id
) AS election
ON election.result_summary_id = rs.id
WHERE election.count IS NULL;
*/