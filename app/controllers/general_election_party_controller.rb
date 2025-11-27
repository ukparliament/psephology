class GeneralElectionPartyController < ApplicationController
  
  def index
    @party_performances = @general_election.party_performance
    
    respond_to do |format|
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"parties-#{'notional-' if @general_election.is_notional}general-election-#{@general_election.polling_on.strftime( '%d-%m-%Y' )}.csv\""
      }
      format.html{
        @page_title = "#{@general_election.common_title} - by party"
        @multiline_page_title = "#{@general_election.common_title} <span class='subhead'>By party</span>".html_safe
        @description = "#{@general_election.common_description} listed by political party."
        @csv_url = general_election_party_list_url( :format => 'csv' )
        @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
        @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
        @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
        @crumb << { label: 'Parties', url: nil }
        @section = 'elections'
        @subsection = 'parties'
        
        if @general_election.is_notional
          render :template => 'general_election_party/index_notional'
        elsif @general_election.publication_state == 0
          render :template => 'general_election_party/index_dissolution'
        elsif @general_election.publication_state == 1
          render :template => 'general_election_party/index_candidates_only'
        elsif @general_election.publication_state == 2
          render :template => 'general_election_party/index_winners_only'
        else
          render :template => 'general_election_party/index'
        end
      }
    end
  end
  
  def show
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    
    @page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@political_party.name}"
    @multiline_page_title = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} UK general election on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} <span class='subhead'>#{@political_party.name}</span>".html_safe
    @description = "#{@general_election.result_type} for #{@general_election.noun_phrase_article} general election to the Parliament of the United Kingdom on #{@general_election.polling_on.strftime( $DATE_DISPLAY_FORMAT )} - #{@political_party.name}."
    @crumb << { label: 'Parliament periods', url: parliament_period_list_url }
    @crumb << { label: @general_election.parliament_period_crumb_label, url: parliament_period_show_url( :parliament_period => @general_election.parliament_period_number) }
    @crumb << { label: @general_election.crumb_label, url: general_election_show_url }
    @crumb << { label: @political_party.name, url: nil }
    @section = 'elections'
  end
end
