class GeneralElectionCountryController < ApplicationController
  
  def index
    @countries = @general_election.top_level_countries_with_elections
    
    @page_title = "#{@general_election.common_title} - countries"
    @multiline_page_title = "#{@general_election.common_title} <span class='subhead'>Countries</span>".html_safe
    @description = "#{@general_election.common_description} listed by country."
    @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
    @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
    @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
    @crumb << { label: 'Countries', url: nil }
    @section = 'elections'
    render :template => 'general_election_country/index_notional' if @general_election.is_notional
      
  end
  
  def show
    country = params[:country]
    @country = Country.find( country )
    @party_performances = @general_election.party_performance_in_country( @country )
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"parties-in-#{@country.name.downcase.gsub( ' ', '-' )}-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
        render :template => 'general_election_party/index'
      }
      format.html{
        @page_title = "#{@general_election.common_title} - #{@country.name} - by party"
        @multiline_page_title = "#{@general_election.common_title} <span class='subhead'>#{@country.name} - by party</span>".html_safe
        @description = "#{@general_election.common_description} in #{@country.name}, listed by political party."
        @csv_url = general_election_country_political_party_list_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: @country.name, url: nil }
        @section = 'elections'
        @subsection = 'parties'
        
        if @general_election.is_notional
          render :template => 'general_election_country_political_party/index_notional'
        elsif @general_election.publication_state == 0
          render :template => 'general_election_country_political_party/index_dissolution'
        elsif @general_election.publication_state == 1
          render :template => 'general_election_country_political_party/index_candidates_only'
        elsif @general_election.publication_state == 2
          render :template => 'general_election_country_political_party/index_winners_only'
        else
          render :template => 'general_election_country_political_party/index'
        end
      }
    end
  end
end
