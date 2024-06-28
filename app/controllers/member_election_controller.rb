class MemberElectionController < ApplicationController
  
  def index
    member = params[:member]
    @member = Member.find_by_mnis_id( member )
    raise ActiveRecord::RecordNotFound unless @member
    @page_title = "#{@member.display_name} - Elections contested"
    @multiline_page_title = "#{@member.display_name}  <span class='subhead'>Elections contested</span>".html_safe
    @elections = @member.elections
    
    @section = 'members'
    @subsection = 'contested'
    @description = "Elections contested by #{@member.display_name}."
    @crumb = "<li><a href='/members'>Members</a></li>"
    @crumb += "<li><a href='/members/#{@member.mnis_id}'>#{@member.display_name}</a></li>"
    @crumb += "<li>Elections contested</li>"
  end
  
  def won
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
    @crumb += "<li><a href='/members/#{@member.mnis_id}'>#{@member.display_name}</a></li>"
    @crumb += "<li>Elections won</li>"
  end
end
