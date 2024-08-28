class GeneralElectionEnglishRegionPoliticalPartyController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find_by_sql(
      "
        SELECT ge.*, pp.number AS parliament_period_number
        FROM general_elections ge, parliament_periods pp
        WHERE ge.parliament_period_id = pp.id
        AND ge.id = #{general_election}
      "
    ).first
    
    country = params[:country]
    english_region = params[:english_region]
    @english_region = EnglishRegion.all.where( 'id = ?', english_region ).where( 'country_id =?', country).first
    
    raise ActiveRecord::RecordNotFound unless @general_election and @english_region
    
    @party_performances = @general_election.party_performance_in_english_region( @english_region )
    
    @valid_vote_count_in_general_election_in_english_region = @general_election.valid_vote_count_in_english_region( @english_region )
    
    if @general_election.is_notional
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - by party"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - by party</span>".html_safe
      @description = "Notional results in #{@english_region.name}, England for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by political party."
    else
      @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - by party"
      @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - by party</span>".html_safe
      @description = "Results in #{@english_region.name}, England for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by political party."
    end
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"parties-in-england-#{@english_region.name.downcase.gsub( ' ', '-' )}-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
        render :template => 'general_election_party/index'
      }
      format.html{
        @crumb << { label: 'General elections', url: general_election_list_url }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: 'England', url: general_election_country_show_url }
        @crumb << { label: @english_region.name, url: nil }
        @section = 'general-elections'
        @subsection = 'parties'
        render :template => 'general_election_english_region_political_party/index_notional' if @general_election.is_notional
      }
    end
  end
  
  def show

    general_election = params[:general_election]
    @general_election = GeneralElection.find_by_sql(
      "
        SELECT ge.*, pp.number AS parliament_period_number
        FROM general_elections ge, parliament_periods pp
        WHERE ge.parliament_period_id = pp.id
        AND ge.id = #{general_election}
      "
    ).first
    
    country = params[:country]
    english_region = params[:english_region]
    @english_region = EnglishRegion.all.where( 'id = ?', english_region ).where( 'country_id =?', country).first
    
    raise ActiveRecord::RecordNotFound unless @general_election and @english_region
    
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    
    @crumb << { label: 'General elections', url: general_election_list_url }
    @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
    @crumb << { label: 'England', url: general_election_country_show_url }
    @crumb << { label: @english_region.name, url: general_election_english_region_show_url }
    @crumb << { label: @political_party.name, url: nil }
    @section = 'general-elections'
    
    if @general_election.is_notional
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - #{@political_party.name}"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - #{@political_party.name}</span>".html_safe
      @description = "Notional results in #{@english_region.name}, England for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@political_party.name}."
      render :template => 'general_election_english_region_political_party/show_notional'
    else
      @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - #{@political_party.name}"
      @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - #{@political_party.name}</span>".html_safe
      @description = "Results in #{@english_region.name}, England for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@political_party.name}."
    end
  end
end
