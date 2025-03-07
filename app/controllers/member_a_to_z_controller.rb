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
    @description = "Winning candidates in elections to the Parliament of the United Kingdom since 2010, listed alphabetically by family name."
    @csv_url = member_list_url( :format => 'csv' )
    @crumb << { label: 'Members', url: member_list_url }
    @crumb << { label: 'A to Z', url: nil }
    @section = 'members'
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
    
    letter = helpers.sanitize(params[:letter])
    @letter = letter.upcase
    
    @members = Member.find_by_sql([
      "
        SELECT m.*, count(c.id)
        FROM members m, candidacies c
        WHERE m.id = c.member_id
        AND c.is_winning_candidacy IS TRUE
        AND UPPER( LEFT( m.family_name, 1) ) = ?
        GROUP BY m.id
        ORDER BY family_name, given_name
      ", @letter
    ])

    raise ActiveRecord::RecordNotFound if @members.empty?
    
    @page_title = "Members - #{@letter}"
    @multiline_page_title = "Members <span class='subhead'>By family name - #{@letter}</span>".html_safe
    @description = "Winning candidates in elections to the Parliament of the United Kingdom since 2010, listed alphabetically by family name, family name beginning #{@letter}."
    @csv_url = member_list_url( :format => 'csv' )
    @crumb << { label: 'Members', url: member_list_url }
    @crumb << { label: @letter, url: nil }
    @section = 'members'
    @subsection = @letter.downcase
  end
end
