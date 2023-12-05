class MemberElectionController < ApplicationController
  
  def index
    member = params[:member]
    @member = Member.find_by_mnis_id( member )
    raise ActiveRecord::RecordNotFound unless @member
    @page_title = "#{@member.display_name} - All elections contested"
    @multiline_page_title = "#{@member.display_name}  <span class='subhead'>All elections contested</span>".html_safe
    @elections = @member.elections
  end
  
  def won
    member = params[:member]
    @member = Member.find_by_mnis_id( member )
    raise ActiveRecord::RecordNotFound unless @member
    @page_title = "#{@member.display_name} - Elections won"
    @multiline_page_title = "#{@member.display_name}  <span class='subhead'>Elections won</span>".html_safe
    @elections_won = @member.elections_won
  end
end
