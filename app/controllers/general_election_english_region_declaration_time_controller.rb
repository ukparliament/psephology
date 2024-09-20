class GeneralElectionEnglishRegionDeclarationTimeController < ApplicationController
  
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
  
    @elections = @general_election.elections_by_declaration_time_in_english_region( @english_region )
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"declaration-time-data-in-england-#{@english_region.name.downcase.gsub( ' ', '-' )}-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
        render :template => 'general_election_declaration_times/index'
      }
      format.html {
        @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - by declaration time"
        @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - by declaration time</span>".html_safe
        @description = "Results in #{@english_region.name}, England for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by declaration time."
        @crumb << { label: 'General elections', url: general_election_list_url }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: 'England', url: general_election_country_show_url }
        @crumb << { label: @english_region.name, url: general_election_english_region_show_url }
        @crumb << { label: 'Declaration times', url: nil }
        @section = 'general-elections'
        @subsection = 'declaration-times'
      }
    end
  end
end
