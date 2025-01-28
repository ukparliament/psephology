class PoliticalPartyByElectionController < ApplicationController

  def index
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    @by_election_candidacies = @political_party.by_election_candidacies
    @political_parties_sharing_registrations = @political_party.political_parties_sharing_registrations
    
    @page_title = "#{@political_party.name} - by-elections"
    @multiline_page_title = "#{@political_party.name} <span class='subhead'>By-elections</span>".html_safe
    @description = "#{@political_party.name} - By-elections."
    @crumb << { label: 'Political parties', url: political_party_winning_list_url }
    @crumb << { label: @political_party.name, url: political_party_show_url( :political_party => @political_party ) }
    @crumb << { label: 'By-elections', url: nil }
    @section = 'political-parties'
    @subsection = 'by-elections'
  end
end
