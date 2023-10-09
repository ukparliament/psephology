class GeneralElectionPartySwitchController < ApplicationController
  
  def index
    @page_title = 'General elections - constituency political party changes'
    
    @nodes = Node.all
    @edges = Edge.all
    
    render layout: "d3"
  end
end
