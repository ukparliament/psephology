class MemberController < ApplicationController
  
  def index
    @page_title = 'Members'
    @members = Member.all.order( 'family_name' ).order( 'given_name' )
  end
  
  def show
    member = params[:member]
    @member = Member.find_by_mnis_id( member )
    @page_title = @member.display_name
    @elections_won = @member.elections_won
    @other_elections_contested = @member.other_elections_contested
  end
end
