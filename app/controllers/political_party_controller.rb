class PoliticalPartyController < ApplicationController
  
  def index
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
    
    @page_title = 'Contesting political parties'
    @description = "Political parties certifying candidates in elections to the Parliament of the United Kingdom since 2010."
    @crumb << { label: 'Political parties', url: political_party_winning_list_url }
    @crumb << { label: 'Contesting parties', url: nil }
    @section = 'political-parties'
    @subsection = 'contested'
  end
  
  def winning
    @political_parties = PoliticalParty.all.where( 'has_been_parliamentary_party IS TRUE' ).order( 'name' )
    
    @page_title = 'Winning political parties'
    @description = "Political parties certifying candidates in elections to the Parliament of the United Kingdom since 2010, where one or more of those candidates have won an election."
    @crumb << { label: 'Political parties', url: nil }
    @section = 'political-parties'
    @subsection = 'won'
  end
  
  def fall
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
    
    @page_title = 'Political parties as Fall b-sides'
    @description = "Fall b-sides."
    @crumb << { label: 'Political parties', url: political_party_winning_list_url }
    @crumb << { label: 'Fall b-sides', url: nil }
    @section = 'political-parties'
  end
  
  def show
    political_party = params[:political_party]
    @political_party = PoliticalParty.find( political_party )
    
    @general_elections = @political_party.general_elections
    
    @page_title = "#{@political_party.name} - general elections"
    @multiline_page_title = "#{@political_party.name} <span class='subhead'>General elections</span>".html_safe
    @description = "General elections contested by #{@political_party.name}."
    @crumb << { label: 'Political parties', url: political_party_winning_list_url }
    @crumb << { label: @political_party.name, url: nil }
    @section = 'political-parties'
    @subsection = 'general-election'
    render :template => 'political_party_general_election/index'
  end
end
