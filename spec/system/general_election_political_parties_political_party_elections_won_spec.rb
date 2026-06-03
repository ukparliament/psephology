require 'rails_helper'

describe "Test for checking page load and data accuracy of general_election/:general_election/political-parties/:political-party/election/won 2024 07 04 GE", type: :system do
	#have to hard code date chosen
	let(:polling_date)	{'2024-07-04'}
	let(:polling_date_as_display)     { '4 July 2024' }
	#difficult to check the majority via simple db query so hard coding no changes to be expected to data at this point
	let(:first_line_of_results_table) {[ 'Aldridge-Brownhills', 'MORTON, Wendy', '70,268', '58.2%', '15,901', '38.9%', '-30.7%', '4,294']}

						

	it 'loads general-election/:general-election/political-parties/:political-party/election/won based on 2024 07 04 GE' do
		#get the general election for the selected polling on date (most recent at time of writing)
			generalelection = GeneralElection.where(polling_on: polling_date).last.id

		#get the political party - first is conservatives (id = 1)
			politicalparty = PoliticalParty.first.id
			partyName = PoliticalParty.first.name

		#pass to general_election_list_path
			visit general_election_party_election_won_path(generalelection, politicalparty)

		#check content on page suggests correct page?
			expect(page).to have_content("Results for the UK general election on #{polling_date_as_display}")
			expect(page).to have_content("Elections won by #{partyName}")
		
	end

	it 'has the same first line of results for the 2024 07 04 election that was there last time' do
		#get the general election for the selected polling on date (most recent at time of writing)
			generalelection = GeneralElection.where(polling_on: polling_date).last.id

		#get the political party
			politicalparty = PoliticalParty.first.id
			partyName = PoliticalParty.first.name


			#pass to general_election_list_path\
			visit general_election_party_election_won_path(generalelection, politicalparty)

			#check content on page suggests correct page?
			first_data_row = all('tbody tr').first

       		cells = first_data_row.all('td').map(&:text)

       		expect(cells).to match_array(first_line_of_results_table)
		
	end

end