class GeneralElectionPartySwitchController < ApplicationController
  
  def index
    @page_title = 'Constituency political party changes across general elections'
    
    @nodes = Node.all
    @edges = Edge.all
    
    render layout: "d3"
  end
end
