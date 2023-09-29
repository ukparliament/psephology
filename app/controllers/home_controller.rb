class HomeController < ApplicationController
  
  def index
    @general_elections = GeneralElection.order( 'polling_on' )
  end
end
