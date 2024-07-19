class PoliticalPartyGeneralElectionController < ApplicationController
  
  def index
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    
    @general_elections = @political_party.general_elections
    
    @page_title = "#{@political_party.name} - general elections"
    @multiline_page_title = "#{@political_party.name} <span class='subhead'>General elections</span>".html_safe
    @description = "#{@political_party.name} - General elections."
    @crumb << { label: 'Political parties', url: political_party_winning_list_url }
    @crumb << { label: @political_party.name, url: political_party_show_url( :political_party => @political_party ) }
    @crumb << { label: 'General elections', url: nil }
    @section = 'political-parties'
  end
end
