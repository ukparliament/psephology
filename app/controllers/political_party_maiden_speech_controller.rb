class PoliticalPartyMaidenSpeechController < ApplicationController

  def index
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    
    @maiden_speeches = @political_party.maiden_speeches
    
    @political_parties_sharing_registrations = @political_party.political_parties_sharing_registrations
    
    @page_title = "#{@political_party.name} - maiden speeches"
    @multiline_page_title = "#{@political_party.name} <span class='subhead'>Maiden speeches</span>".html_safe
    @description = "Maiden speeches made by #{@political_party.name} Members."
    @crumb << { label: 'Political parties', url: political_party_winning_list_url }
    @crumb << { label: @political_party.name, url: political_party_show_url }
    @crumb << { label: 'Maiden speeches', url: nil }
    @section = 'political-parties'
    @subsection = 'maiden-speeches'
  end
end
