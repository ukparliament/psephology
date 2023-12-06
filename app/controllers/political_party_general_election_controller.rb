class PoliticalPartyGeneralElectionController < ApplicationController
  
  def index
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    @page_title = "#{@political_party.name} - general elections"
    @multiline_page_title = "#{@political_party.name} <span class='subhead'>General elections</span>".html_safe
    
    @general_elections = @political_party.general_elections
  end
end
