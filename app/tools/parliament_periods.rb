# frozen_string_literal: true

class ParliamentPeriods < MCP::Tool
  title "List Parliament periods"
  description "A tool to list Parliament periods having elections data"
  input_schema(
    properties: {
    },
  )

  class << self
    def call
    
      parliament_periods = ParliamentPeriod.find_by_sql(
        "
          SELECT
            pp.*,
            general_election.polling_on AS general_election_polling_on,
            general_election.id AS general_election_id,
            by_election.count AS by_election_count
          FROM parliament_periods pp
        
          INNER JOIN (
            SELECT *
            FROM general_elections
            WHERE is_notional IS FALSE
          ) general_election
          ON general_election.parliament_period_id = pp.id
        
          LEFT JOIN (
            SELECT count(id) AS count, parliament_period_id
            FROM elections
            WHERE general_election_id IS NULL
            AND  is_notional IS FALSE
            GROUP BY parliament_period_id
          ) by_election
          ON by_election.parliament_period_id = pp.id
        
          ORDER BY summoned_on desc
        "
      )
      
      MCP::Tool::Response.new(
        [
          {
            type: "text",
            text: parliament_periods.to_json,
          }
        ]
      )
    end
  end
end