class MemberController < ApplicationController
  
  def index
    @members = Member.all.order( 'family_name' ).order( 'given_name' )
    @letters = Member.find_by_sql(
      "
        SELECT UPPER( ( LEFT ( m.family_name, 1 ) ) ) AS letter
        FROM members m, candidacies c
        WHERE m.id = c.member_id
        AND c.is_winning_candidacy IS TRUE
        GROUP BY letter
        ORDER BY letter;
      "
    )
    @members = Member.find_by_sql(
      "
        SELECT m.*, count(c.id)
        FROM members m, candidacies c
        WHERE m.id = c.member_id
        AND c.is_winning_candidacy IS TRUE
        GROUP BY m.id
        ORDER BY family_name, given_name
      "
    )
    
    @page_title = 'Members'
    @description = "Winning candidates in elections to the Parliament of the United Kingdom since 2010."
    @csv_url = member_list_url( :format => 'csv' )
    @crumb << { label: 'Members', url: nil }
    @section = 'members'
  end
  
  def show
    member = params[:member]
    @member = Member.find_by_mnis_id( member )
    raise ActiveRecord::RecordNotFound unless @member
    
    @elections_won = @member.elections_won
    
    @maiden_speech = @member.maiden_speech
    
    @page_title = "#{@member.display_name} - Elections won"
    @multiline_page_title = "#{@member.display_name}  <span class='subhead'>Elections won</span>".html_safe
    @description = "Elections won by #{@member.display_name}."
    @crumb << { label: 'Members', url: member_list_url }
    @crumb << { label: @member.display_name, url: nil }
    @section = 'members'
    @subsection = 'won'
    
    render :template => 'member_election/won'
  end
end
