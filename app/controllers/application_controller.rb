class ApplicationController < ActionController::Base 
  
  $DATE_DISPLAY_FORMAT = '%-d %B %Y'
  $CRUMB_DATE_DISPLAY_FORMAT = '%B %Y'
  $DATE_TIME_DISPLAY_FORMAT = '%H:%M on %-d %B %Y'
  $DECLARATION_TIME_DISPLAY_FORMAT = '%A %-d at %H:%M'
  $TIME_DISPLAY_FORMAT = '%H:%M'
  $COVERAGE_PERIOD = '2010 to 2019'
  

  before_action do
    expires_in 3.minutes, :public => true
    create_crumb_container
    get_general_election
  end
  
  def create_crumb_container
    @crumb = []
  end
  
  private
    def get_general_election
    
      # If a general election parameter has been passed ...
      if params[:general_election].present?
      
        # ... we get the general election ID.
        general_election = params[:general_election]
      
        # We get the general election decorated with parliament period information needed to construct the crumb.
        @general_election = GeneralElection.find_by_sql(
          "
            SELECT ge.*, pp.number AS parliament_period_number
            FROM general_elections ge, parliament_periods pp
            WHERE ge.parliament_period_id = pp.id
            AND ge.id = #{general_election}
          "
        ).first
        raise ActiveRecord::RecordNotFound unless @general_election
      end
    end
end
