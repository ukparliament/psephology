class MemberController < ApplicationController
  
  def index
    @page_title = 'Members'
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
    
    @section = 'members'
    @description = "Winning candidates in elections to the Parliament of the United Kingdom since 2010."
    @csv_url = member_list_url( :format => 'csv' )
    @crumb = "<li>Members</li>".html_safe
  end
  
  def show
    member = params[:member]
    @member = Member.find_by_mnis_id( member )
    raise ActiveRecord::RecordNotFound unless @member
    @page_title = "#{@member.display_name} - Elections won"
    @multiline_page_title = "#{@member.display_name}  <span class='subhead'>Elections won</span>".html_safe
    @elections_won = @member.elections_won
    
    @section = 'members'
    @subsection = 'won'
    @description = "Elections won by #{@member.display_name}."
    @crumb = "<li><a href='/members'>Members</a></li>"
    @crumb += "<li>#{@member.display_name}</li>"
  end
end
