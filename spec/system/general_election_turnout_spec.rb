require 'rails_helper'

describe "Test for checking page load and data accuracy of general_election/:general_election/turnout 2024 07 04 GE", type: :system do
	#have to hard code date choosen
	let(:polling_date)	{'2024-07-04'}
	let(:polling_date_as_display)     { '4 July 2024' }
	#difficult to check the turnout % via simple db query so hard coding no changes to be expected to data at this point
	let(:first_line_of_results_table) {[ '1', 'Harpenden and Berkhamsted', 'COLLINS, Victoria', 'LD', '54,336', '72,242', '75.2%']}


	it 'loads general-election/:general-election/vote-share based on 2024 07 04 GE ' do
		#get the general election for the selected polling on date (most recent at time of writing)
			generalelection = GeneralElection.where(polling_on: polling_date).last.id

			#pass to general_election_list_path
			visit general_election_turnout_list_path(generalelection)

			#check content on page suggests correct page?
			expect(page).to have_content("Results for the UK general election on #{polling_date_as_display}")
			expect(page).to have_content("By turnout")
		
	end

	it 'has the same first line of results for the 2024 07 04 election that was there last time' do
		#get the general election for the selected polling on date (most recent at time of writing)
			generalelection = GeneralElection.where(polling_on: polling_date).last.id

			#pass to general_election_list_path
			visit general_election_turnout_list_path(generalelection)

			#check content on page suggests correct page?
			first_data_row = all('tbody tr').first

       		cells = first_data_row.all('td').map(&:text)

       		expect(cells).to match_array(first_line_of_results_table)
		
	end

end