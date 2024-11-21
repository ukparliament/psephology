class MemberElectionController < ApplicationController
  
  def index
    member = params[:member]
    @member = Member.find_by_mnis_id( member )
    raise ActiveRecord::RecordNotFound unless @member
    
    @elections = @member.elections
    
    @page_title = "#{@member.display_name} - Elections contested"
    @multiline_page_title = "#{@member.display_name}  <span class='subhead'>Elections contested</span>".html_safe
    @description = "Elections contested by #{@member.display_name}."
    @crumb << { label: 'Members', url: member_list_url }
    @crumb << { label: @member.display_name, url: member_show_url( :member => @member.mnis_id ) }
    @crumb << { label: 'Elections contested', url: nil }
    @section = 'members'
    @subsection = 'contested'
  end
  
  def won
    member = params[:member]
    @member = Member.find_by_mnis_id( member )
    raise ActiveRecord::RecordNotFound unless @member
    
    @elections_won = @member.elections_won
    
    @maiden_speech = @member.maiden_speech
    
    @page_title = "#{@member.display_name} - Elections won"
    @multiline_page_title = "#{@member.display_name}  <span class='subhead'>Elections won</span>".html_safe
    @description = "Elections won by #{@member.display_name}."
    @crumb << { label: 'Members', url: member_list_url }
    @crumb << { label: @member.display_name, url: member_show_url( :member => @member.mnis_id ) }
    @crumb << { label: 'Elections won', url: nil }
    @section = 'members'
    @subsection = 'won'
  end
end
