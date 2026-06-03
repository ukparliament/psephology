require 'rails_helper'

describe "Test for checking page load ONLY of general_election/:general_election/declaration-times 2024 07 04 GE", type: :system do
	#have to hard code date choosen
	let(:polling_date)	{'2024-07-04'}
	let(:polling_date_as_display)     { '4 July 2024' }


	it 'loads general-election/:general-election/declaration-times based on 2024 07 04 GE ' do
		#get the general election for the selected polling on date (most recent at time of writing)
			generalelection = GeneralElection.where(polling_on: polling_date).last.id

			#pass to general_election_list_path
			visit general_election_declaration_time_list_path(generalelection)

			#check content on page suggests correct page?
			expect(page).to have_content("Results for the UK general election on #{polling_date_as_display}")
			expect(page).to have_content("By declaration time")
		
	end

end