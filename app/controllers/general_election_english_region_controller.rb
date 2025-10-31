class GeneralElectionEnglishRegionController < ApplicationController
  
  def index
    country = params[:country]
    @country = Country.find( country )
    @english_regions = @general_election.english_regions_in_country( @country )
    
    @page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - English regions"
    @multiline_page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>English regions</span>".html_safe
    @description = "#{@general_election.result_type} in #{@country.name} for #{@general_election.noun_phrase_article} general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listing regions in England."
    @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
    @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
    @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
    @crumb << { label: @country.name, url: general_election_country_show_url }
    @crumb << { label: 'Regions', url: nil }
    @section = 'elections'
  end
  
  def show
    country = params[:country]
    english_region = params[:english_region]
    @english_region = EnglishRegion.all.where( 'id = ?', english_region ).where( 'country_id =?', country).first
    raise ActiveRecord::RecordNotFound unless @english_region
    @party_performances = @general_election.party_performance_in_english_region( @english_region )
    
    @page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@english_region.name}, England - by party"
    @multiline_page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@english_region.name}, England - by party</span>".html_safe
    @description = "#{@general_election.result_type} in #{@english_region.name}, England for #{@general_election.noun_phrase_article} general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}, listed by political party."
    @csv_url = general_election_english_region_political_party_list_url( :format => 'csv' )
    @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
    @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
    @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
    @crumb << { label: 'England', url: general_election_country_show_url }
    @crumb << { label: @english_region.name, url: nil }
    @section = 'elections'
    @subsection = 'parties'
    
    if @general_election.is_notional
      render :template => 'general_election_english_region_political_party/index_notional'
    elsif @general_election.publication_state > 2
      render :template => 'general_election_english_region_political_party/index'
    elsif @general_election.publication_state == 1
      render :template => 'general_election_english_region_political_party/index_candidates_only'
    elsif @general_election.publication_state == 2
      render :template => 'general_election_english_region_political_party/index_winners_only'
    end
  end
end
