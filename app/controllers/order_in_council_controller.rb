class OrderInCouncilController < ApplicationController
  
  def index
    @orders_in_council = OrderInCouncil.all.order( 'made_on desc' )
    @page_title = "Orders in Council"
  end
  
  def show
    order_in_council = params[:order_in_council]
    puts order_in_council
    @order_in_council = OrderInCouncil.find_by_url_key( order_in_council )
    
    puts @order_in_council.inspect
    raise ActiveRecord::RecordNotFound unless @order_in_council
    @boundary_sets = @order_in_council.boundary_sets
    @page_title = @order_in_council.title
  end
end
