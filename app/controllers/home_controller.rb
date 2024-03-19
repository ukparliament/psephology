class HomeController < ApplicationController
  
  def index
    @general_elections = GeneralElection.order( 'polling_on' )
    expires_in 3.minutes, :public => true
  end
end
