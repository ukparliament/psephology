class PoliticalPartyGeneralElectionController < ApplicationController
  
  def index
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    @page_title = "#{@political_party.name} - general elections"
    @multiline_page_title = "#{@political_party.name} <span class='subhead'>General elections</span>".html_safe
    
    @general_elections = @political_party.general_elections
    
    @section = 'political-parties'
    @description = "#{@political_party.name} - General elections."
    @crumb = "<li><a href='/political-parties/winning'>Political parties</a></li>"
    @crumb += "<li><a href='/political-parties/#{@political_party.id}'>#{@political_party.name}</a></li>"
    @crumb += "<li>General elections</li>"
  end
end
