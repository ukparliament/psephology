class GeneralElectionEnglishRegionConstituencyAreaController < ApplicationController
  
  def index
    country = params[:country]
    @country = Country.find( country )
    english_region = params[:english_region]
    @english_region = EnglishRegion.all.where( 'id = ?', english_region ).where( 'country_id =?', country).first
    raise ActiveRecord::RecordNotFound unless @english_region
    @elections = @general_election.elections_in_english_region( @english_region)
    
    @page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - by constituency"
    @multiline_page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - by constituency</span>".html_safe
    @description = "#{@general_election.result_type} in #{@english_region.name}, England for #{@general_election.noun_phrase_article} general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by constituencies."
    @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
    @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
    @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
    @crumb << { label: 'England', url: general_election_country_show_url }
    @crumb << { label: @english_region.name, url: general_election_english_region_show_url }
    @crumb << { label: 'Constituencies', url: nil }
    @section = 'elections'
    @subsection = 'constituency-areas'
    
    render :template => 'general_election_english_region_constituency_area/index_notional' if @general_election.is_notional
  end
end
