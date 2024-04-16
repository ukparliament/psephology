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
    @multiline_page_title = "Members  <span class='subhead'>A to Z</span>".html_safe
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
    @multiline_page_title = "Members  <span class='subhead'>By family name -  #{@letter}</span>".html_safe
    
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
  end
end
