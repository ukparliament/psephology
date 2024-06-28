class MemberAToZController < ApplicationController
  
  def index
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
    @page_title = "Members - A to Z"
    @multiline_page_title = "Members <span class='subhead'>A to Z</span>".html_safe
    
    @section = 'members'
    @description = "Winning candidates in elections to the Parliament of the United Kingdom since 2010, listed alphabetically by family name."
    @csv_url = member_list_url( :format => 'csv' )
    @crumb = "<li><a href='/members'>Members</a></li>"
    @crumb += '<li>A to Z</li>'
  end
  
  def show
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
    
    letter = params[:letter]
    @letter = letter.upcase
    @page_title = "Members - #{@letter}"
    @multiline_page_title = "Members <span class='subhead'>By family name - #{@letter}</span>".html_safe
    
    @members = Member.find_by_sql(
      "
        SELECT m.*, count(c.id)
        FROM members m, candidacies c
        WHERE m.id = c.member_id
        AND c.is_winning_candidacy IS TRUE
        AND UPPER( LEFT( m.family_name, 1) ) = '#{@letter}'
        GROUP BY m.id
        ORDER BY family_name, given_name
      "
    )

    raise ActiveRecord::RecordNotFound if @members.empty?
    
    @section = 'members'
    @subsection = @letter.downcase
    @description = "Winning candidates in elections to the Parliament of the United Kingdom since 2010, listed alphabetically by family name, family name beginning #{@letter}."
    @csv_url = member_list_url( :format => 'csv' )
    @crumb = "<li><a href='/members'>Members</a></li>"
    @crumb += "<li>#{@letter}</li>"
  end
end
