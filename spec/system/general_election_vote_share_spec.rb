require 'rails_helper'

describe "Test for checking page load and data accuracy of general_election/:general_election/vote-share 20244 07 04 GE" type: :system do
	let(:polling_date)	{'2024-07-04'}
	let(:polling_date_as_display)     { '4 July 2024' }


	it 'loads general-election/:general-election/vote-share based on 2024 07 04 GE ' do
		#get the general election for the selected polling on date (most recent at time of writing)
			generalelection = GeneralElection.where(polling_on: polling_date).last.id

			#pass to general_election_list_path
			visit general_election_vote_share_list_path(generalelection)

			#check content on page suggests correct page?
			expect(page).to have_content("Results for the UK general election on #{polling_date_as_display}")
			expect(page).to have_content("By vote share")
		
	end

	
