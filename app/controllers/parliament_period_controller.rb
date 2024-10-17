class ParliamentPeriodController < ApplicationController
  
  def index
    @parliament_periods = ParliamentPeriod.find_by_sql(
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
    
    @page_title = 'Parliament periods'
    @description = 'Parliaments of the United Kingdom since 1801.'
    @csv_url = parliament_period_list_url( :format => 'csv' )
    @crumb << { label: 'Parliament periods', url: nil }
    @section = 'parliament-periods'
  end
  
  def show
    parliament_period = params[:parliament_period]
    @parliament_period = ParliamentPeriod.find_by_number( parliament_period )
    raise ActiveRecord::RecordNotFound unless @parliament_period
    
    @general_election = @parliament_period.general_election
    @by_elections = @parliament_period.by_elections
    @boundary_sets = @parliament_period.boundary_sets_for_general_elections
    
    @page_title = "#{@parliament_period.number.ordinalize} Parliament of the United Kingdom"
    @description = "The #{@parliament_period.number.ordinalize} Parliament of the United Kingdom."
    @crumb << { label: 'Parliament periods', url: parliament_period_show_url }
    @crumb << { label: "#{@parliament_period.number.ordinalize} Parliament", url: nil }
    @section = 'parliament-periods'
  end
end
