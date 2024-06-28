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
    
    @section = 'political-parties'
    @subsection = 'contested'
    @description = "Political parties certifying candidates in elections to the Parliament of the United Kingdom since 2010."
    @crumb = "<li><a href='/political-parties/winning'>Political parties</a></li>"
    @crumb += "<li>Contesting parties</li>"
  end
  
  def winning
    @page_title = 'Winning political parties'
    @political_parties = PoliticalParty.all.where( 'has_been_parliamentary_party IS TRUE' ).order( 'name' )
    
    @section = 'political-parties'
    @subsection = 'won'
    @description = "Political parties certifying candidates in elections to the Parliament of the United Kingdom since 2010, where one or more of those candidates have won an election."
    @crumb = "<li>Political parties</li>"
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
    
    @section = 'political-parties'
    @description = "Fall b-sides."
    @crumb = "<li><a href='/political-parties/winning'>Political parties</a></li>"
    @crumb += "<li>Fall b-sides</li>"
  end
  
  def show
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    @page_title = @political_party.name
    
    @general_elections = @political_party.general_elections
    
    @section = 'political-parties'
    @description = "#{@political_party.name}."
    @crumb = "<li><a href='/political-parties/winning'>Political parties</a></li>"
    @crumb += "<li>#{@political_party.name}</li>"
  end
end
