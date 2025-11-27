class GeneralElectionCountryConstituencyAreaController < ApplicationController
  
  def index
    country = params[:country]
    @country = Country.find( country )
    @countries = @general_election.child_countries_with_elections_in_country( @country )
    @english_regions = @general_election.english_regions_in_country( @country )
    @elections = @general_election.elections_in_country_without_electorate( @country)
    
    @page_title = "#{@general_election.common_title} - #{@country.name} - by constituency"
    @multiline_page_title = "#{@general_election.common_title} <span class='subhead'>#{@country.name} - by constituency</span>".html_safe
    @description = "#{@general_election.common_description} in #{@country.name}, listed by constituency."
    @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
    @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
    @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
    @crumb << { label: @country.name, url: general_election_country_show_url }
    @crumb << { label: 'Constituencies', url: nil }
    @section = 'elections'
    @subsection = 'constituency-areas'
  end
end
