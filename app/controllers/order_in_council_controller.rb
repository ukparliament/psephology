class OrderInCouncilController < ApplicationController
  
  def index
    @orders_in_council = OrderInCouncil.all.order( 'title' )
    @page_title = "Orders in Council"
  end
  
  def show
    order_in_council = params[:order_in_council]
    @order_in_council = OrderInCouncil.find( order_in_council )
    @boundary_sets = @order_in_council.boundary_sets
    @page_title = @order_in_council.title
  end
end
