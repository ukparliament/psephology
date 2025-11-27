class GeneralElectionMapController < ApplicationController
  
  def index
    @countries_having_first_elections_in_boundary_set = @general_election.countries_having_first_elections_in_boundary_set
    
    @page_title = "#{@general_election.result_type} for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - map"
    @multiline_page_title = "#{@general_election.result_type} for a UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>Map</span>".html_safe
    @description = "Hexmap of #{@general_election.result_type.downcase} for #{@general_election.noun_phrase_article} general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )}."
    @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
    @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
    @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
    @crumb << { label: 'Map', url: nil }
    @section = 'elections'
    @subsection = 'map'
  end
end
