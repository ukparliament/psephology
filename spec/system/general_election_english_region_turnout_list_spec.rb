require 'rails_helper'

describe "Test for checking page load and data accuracy of general_election/:general_election/countries/2/english-regions/:english-region/turnout 2024 07 04 GE", type: :system do
	#have to hard code date chosen
	let(:polling_date)	{'2024-07-04'}
	let(:polling_date_as_display)     { '4 July 2024' }
	#difficult to check the first line via simple db query so hard coding no changes to be expected to data at this point
	let(:first_line_of_results_table) {['1','Winchester',	'CHAMBERS, Danny',	'LD',	'57,076',	'78,289',	'72.9%']}
	
	
	it 'loads general-election/:general-election/countries/2/english-regions/:english-region/turnout based on 2024 07 04 GE' do
		#test great britian and then the others as query can be a bit different
		#get the general election for the selected polling on date (most recent at time of writing)
			generalelection = GeneralElection.where(polling_on: polling_date).last.id

		#get the country - first with parent id is England
			country = Country.where(parent_country_id: '1').first.id
			countryName = Country.where(parent_country_id: '1').first.name

		#get the english region
			englishregion = EnglishRegion.where(country_id: country).first.id
			englishregionName = EnglishRegion.where(country_id: country).first.name

		#pass to general_election_list_path
			visit general_election_english_region_turnout_list_path(generalelection, country, englishregion)

		#check content on page suggests correct page?
			expect(page).to have_content("Results for the UK general election on #{polling_date_as_display}")
			expect(page).to have_content("#{englishregionName}, #{countryName} - by turnout")
		
	end

	it 'has the same first line of results for GB for the 2024 07 04 election that was there last time' do
		#get the general election for the selected polling on date (most recent at time of writing)
			generalelection = GeneralElection.where(polling_on: polling_date).last.id



		#get the country - first with parent id is England
			country = Country.where(parent_country_id: '1').first.id
			countryName = Country.where(parent_country_id: '1').first.name

		#get the english region
			englishregion = EnglishRegion.where(country_id: country).first.id
			englishregionName = EnglishRegion.where(country_id: country).first.name


		#pass to general_election_list_path\
			visit general_election_english_region_turnout_list_path(generalelection, country, englishregion)

			#check content on page suggests correct page?
			first_data_row = all('tbody tr').first

       		cells = first_data_row.all('td').map(&:text)

       		expect(cells).to match_array(first_line_of_results_table)
		
	end

end