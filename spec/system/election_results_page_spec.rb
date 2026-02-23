require 'rails_helper'

describe "Test that pages to navigate to election/:election load and result returns known result", type: :system do
  context "Most recent election and alphabetically first constituency election" do
  #let (:polling_date)                 { GeneralElection.select(:polling_on).order(polling_on: :desc).first } #dynamic set polling on date to earliest to first in list
  let (:polling_date)                 { '2024-07-04' }
  let (:polling_date_as_link)         { '2024 - 4 July' }
  let (:first_constituency)           { 'Aberafan Maesteg' } ##get the alphabetically first constituency area in the 
  let (:first_line_of_results_table)  {['KINNOCK, Stephen','Lab','17,838','49.9%','-3.0%'] }

# This is using the page nav to get there
    it 'loads the elections page' do
      visit '/elections'
      expect(page).to have_content("General elections")
      expect(page).to have_content("By-elections") ##has content
    end

#lets get to an actualy 'election' result
    it 'navigates to specfic election page via poling_date_as link and Constituencies' do
      
      visit '/elections'

      click_on polling_date_as_link

      click_on 'Constituencies'

      click_on first_constituency

      #expect(page).to have_content("General election for the constituency of #{first_constituency} on #{polling_date}")

    end

#check there is data we agree with here
    it 'loads data which matches the previous iteration of the live website' do
       visit '/elections'

       click_on polling_date_as_link

       click_on 'Constituencies'

       click_on first_constituency

       first_data_row = all('tbody tr').first

       cells = first_data_row.all('td').map(&:text)
       expect(cells).to match_array(first_line_of_results_table)

    end
  end
end