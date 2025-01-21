class GeneralElectionConstituencyAreaController < ApplicationController
  
  def index
    @countries = @general_election.top_level_countries_with_elections
    @elections = @general_election.elections
    
    @page_title = "#{@general_election.result_type} for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - by constituency"
    @multiline_page_title = "#{@general_election.result_type} for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>By constituency</span>".html_safe
    @description = "Elections taking place as part of #{@general_election.noun_phrase_article} #{@general_election.general_election_type.downcase} to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
    @description = "#{@general_election.result_type} for a general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} listed by constituency."
    @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
    @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
    @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
    @crumb << { label: 'Constituencies', url: nil }
    @section = 'elections'
    @subsection = 'constituency-areas'
    
    render :template => 'general_election_constituency_area/index_notional' if @general_election.is_notional
  end
end
