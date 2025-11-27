class GeneralElectionConstituencyAreaController < ApplicationController
  
  def index
    @countries = @general_election.top_level_countries_with_elections
    @elections = @general_election.elections_without_electorate
    
    @page_title = "#{@general_election.common_title} - by constituency"
    @multiline_page_title = "#{@general_election.common_title} <span class='subhead'>By constituency</span>".html_safe
    @description = "#{@general_election.common_description} listed by constituency."
    @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
    @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
    @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
    @crumb << { label: 'Constituencies', url: nil }
    @section = 'elections'
    @subsection = 'constituency-areas'
    
    render :template => 'general_election_constituency_area/index_notional' if @general_election.is_notional
  end
end
