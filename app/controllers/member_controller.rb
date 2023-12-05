class MemberController < ApplicationController
  
  def index
    @page_title = 'Members'
    @members = Member.all.order( 'family_name' ).order( 'given_name' )
  end
  
  def show
    member = params[:member]
    @member = Member.find_by_mnis_id( member )
    raise ActiveRecord::RecordNotFound unless @member
    @page_title = "#{@member.display_name} - Elections won"
    @multiline_page_title = "#{@member.display_name}  <span class='subhead'>Elections won</span>".html_safe
    @elections_won = @member.elections_won
  end
end
