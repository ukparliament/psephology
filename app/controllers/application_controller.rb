class ApplicationController < ActionController::Base 
  
  $DATE_DISPLAY_FORMAT = '%-d %B %Y'
  $CRUMB_DATE_DISPLAY_FORMAT = '%B %Y'
  $DATE_TIME_DISPLAY_FORMAT = '%H:%M on %-d %B %Y'
  $DECLARATION_TIME_DISPLAY_FORMAT = '%A %-d at %H:%M'
  $TIME_DISPLAY_FORMAT = '%H:%M'
  $COVERAGE_PERIOD = '2010 to 2019'
  $CANDIDACIES_ANNOUNCED_ON = ENV["CANDIDACIES_ANNOUNCED_ON"]
  

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
      general_election_id = params[:general_election].to_i

      # We get the general election decorated with parliament period information needed to construct the crumb.
      @general_election = GeneralElection.find_by_sql([
        "
          SELECT ge.*, pp.number AS parliament_period_number, geps.state AS publication_state
          FROM general_elections ge, parliament_periods pp, general_election_publication_states geps
          WHERE ge.parliament_period_id = pp.id
          AND ge.id = ?
          AND ge.general_election_publication_state_id = geps.id
        ", general_election_id
      ]).first
      raise ActiveRecord::RecordNotFound unless @general_election
    end
  end

  def get_boundary_set
    boundary_set_id = params[:boundary_set]

    boundary_set = BoundarySet.find_by_sql([
      "
        SELECT bs.*, c.name AS country_name
        FROM boundary_sets bs, countries c
        WHERE bs.country_id = c.id
        AND bs.id = ?
      ", boundary_set_id
    ]).first
    raise ActiveRecord::RecordNotFound unless boundary_set

    boundary_set
  end

  def get_legislation_item
    legislation_item_id = params[:legislation_item]

    legislation_item = LegislationItem.find_by_sql([
      "
        SELECT li.*, lt.abbreviation AS legislation_type_abbreviation
        FROM legislation_items li, legislation_types lt
        WHERE li.url_key = ?
        AND li.legislation_type_id = lt.id
      ", legislation_item_id
    ]).first
    raise ActiveRecord::RecordNotFound unless legislation_item
    legislation_item
  end
end
