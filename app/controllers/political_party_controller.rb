class PoliticalPartyController < ApplicationController
  
  def index
    @page_title = 'Political parties'
    @political_parties = PoliticalParty.all.order( 'name' )
  end
  
  def parliamentary
    @page_title = 'Parliamentary political parties'
    @political_parties = PoliticalParty.all.where( 'has_been_parliamentary_party IS TRUE' ).order( 'name' )
  end
  
  def fall
    @page_title = 'Political parties as Fall b-sides'
    @fall = ''
    @words = []
    political_parties = PoliticalParty.all.order( 'name' )
    political_parties.each do |political_party|
      political_party.name.split( ' ' ).each do |word|
        @words << word unless @words.include?( word )
      end
    end
    numbers = [1,2,3].each do |number|
      @fall += @words[rand( 0 .. @words.length - 1 )] + ' '
    end
  end
  
  def show
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    @page_title = @political_party.name
    
    @general_elections = @political_party.general_elections
  end
end
