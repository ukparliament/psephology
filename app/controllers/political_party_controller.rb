class PoliticalPartyController < ApplicationController
  
  def index
    @page_title = 'Contesting political parties'
    @political_parties = PoliticalParty.find_by_sql(
      "
        SELECT pp.*
        FROM political_parties pp, certifications c
        WHERE pp.id = c.political_party_id
        AND c.adjunct_to_certification_id IS NULL
        GROUP BY pp.id
        ORDER BY pp.name
      "
    )
  end
  
  def winning
    @page_title = 'Winning political parties'
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
