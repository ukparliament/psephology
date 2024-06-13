class ApplicationController < ActionController::Base
  
  $DATE_DISPLAY_FORMAT = '%-d %B %Y'
  $DATE_TIME_DISPLAY_FORMAT = '%H:%M on %-d %B %Y'
  $DECLARATION_TIME_DISPLAY_FORMAT = '%A %-d at %H:%M'
  $TIME_DISPLAY_FORMAT = '%H:%M'
  $COVERAGE_PERIOD = '2010 to 2019'
  

  before_action do
    expires_in 3.minutes, :public => true
  end
end
