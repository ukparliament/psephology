class PoliticalPartyByElectionParliamentPeriodController < ApplicationController

  def index
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    @parliament_periods_having_by_elections = @political_party.parliament_periods_having_by_elections
    @political_parties_sharing_registrations = @political_party.political_parties_sharing_registrations
    
    @page_title = "#{@political_party.name} - by-elections by Parliament"
    @multiline_page_title = "#{@political_party.name} <span class='subhead'>By-elections by Parliament</span>".html_safe
    @description = "#{@political_party.name} - By-elections by Parliament."
    @crumb << { label: 'Political parties', url: political_party_winning_list_url }
    @crumb << { label: @political_party.name, url: political_party_show_url( :political_party => @political_party ) }
    @crumb << { label: 'By-elections', url: nil }
    @section = 'political-parties'
    @subsection = 'by-elections'
  end
  
  def show
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    @political_parties_sharing_registrations = @political_party.political_parties_sharing_registrations
    parliament_period = params[:parliament_period]
    @parliament_period = ParliamentPeriod.find_by_number( parliament_period )
    raise ActiveRecord::RecordNotFound unless @parliament_period
    @by_election_candidacies = @political_party.by_election_candidacies_in_parliament_period( @parliament_period )
    raise ActiveRecord::RecordNotFound if @by_election_candidacies.empty?
    
    @page_title = "#{@political_party.name} - by-elections in the #{@parliament_period.number.ordinalize} Parliament"
    @multiline_page_title = "#{@political_party.name} <span class='subhead'>By-elections in the #{@parliament_period.number.ordinalize} Parliament</span>".html_safe
    @description = "#{@political_party.name} - By-elections with certified candidates in the #{@parliament_period.number.ordinalize} Parliament."
    @crumb << { label: 'Political parties', url: political_party_winning_list_url }
    @crumb << { label: @political_party.name, url: political_party_show_url( :political_party => @political_party ) }
    @crumb << { label: 'By-elections', url: political_party_by_election_parliament_period_list_url }
    @crumb << { label: "#{@parliament_period.number.ordinalize} Parliament", url: nil }
    @section = 'political-parties'
    @subsection = 'by-elections'
  end
end
