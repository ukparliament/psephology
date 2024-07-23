class GeneralElectionEnglishRegionController < ApplicationController
  
  def index
    general_election = params[:general_election]
    @general_election = GeneralElection.find( general_election )
    
    country = params[:country]
    @country = Country.find( country )
    
    @english_regions = @general_election.english_regions_in_country( @country )
    
    @crumb << { label: 'General elections', url: general_election_list_url }
    @crumb << { label: @general_election.crumb_label, url: general_election_party_list_url }
    @crumb << { label: @country.name, url: general_election_country_political_party_list_url }
    @crumb << { label: 'Regions', url: nil }
    @section = 'general-elections'
    
    if @general_election.is_notional
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - English regions"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>English regions</span>".html_safe
      @description = "Notional results for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listing regions in England."
      render :template => 'general_election_english_region/index_notional'
    else
      @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - English regions"
      @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>English regions</span>".html_safe
      @description = "Results for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listing regions in England."
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
    @country = Country.find( country )
    
    country = params[:country]
    english_region = params[:english_region]
    @english_region = EnglishRegion.all.where( 'id = ?', english_region ).where( 'country_id =?', country).first
    
    raise ActiveRecord::RecordNotFound unless @general_election and @english_region

    @elections = @general_election.elections_in_english_region( @english_region)
    
    @crumb << { label: 'General elections', url: general_election_list_url }
    @crumb << { label: @general_election.crumb_label, url: general_election_party_list_url }
    @crumb << { label: @country.name, url: general_election_country_political_party_list_url }
    @crumb << { label: @english_region.name, url: general_election_english_region_political_party_list_url }
    @crumb << { label: 'Constituencies', url: nil }
    @section = 'general-elections'
    @subsection = 'constituency-areas'
    
    if @general_election.is_notional
      @page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - by constituency"
      @multiline_page_title = "Notional results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - by constituency</span>".html_safe
      @description = "Notional results for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by constituencies in #{@english_region.name}, England."
      render :template => 'general_election_english_region/show_notional'
    else
      @page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - by constituency"
      @multiline_page_title = "Results for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - by constituency</span>".html_safe
      @description = "Results for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by constituencies in #{@english_region.name}, England."
    end
  end
end
