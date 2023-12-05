class MemberElectionsController < ApplicationController
  
  def index

    member = params[:member]
    @member = Member.find_by_mnis_id( member )
    raise ActiveRecord::RecordNotFound unless @member
    @page_title = @member.display_name
    @elections_won = @member.elections_won
    @other_elections_contested = @member.other_elections_contested
  end
end
