require 'rails_helper'

describe "Test for checking page load and data accuracy of general_election/:general_election/countries/:country 2024 07 04 GE", type: :system do
	#have to hard code date chosen
	let(:polling_date)	{'2024-07-04'}
	let(:polling_date_as_display)     { '4 July 2024' }
	#difficult to check the first line via simple db query so hard coding no changes to be expected to data at this point
	#one for gb
	let(:first_line_of_results_table_gb) {['Labour', '631', '9,708,716', '34.6%', '411']}
	#one for england				
	let(:first_line_of_results_table_en) {['Labour', '542', '8,369,183', '34.4%', '347']}

						

	it 'loads general-election/:general-election/countries/:country Great Britian based on 2024 07 04 GE' do
		#test great britian and then the others as query can be a bit different
		#get the general election for the selected polling on date (most recent at time of writing)
			generalelection = GeneralElection.where(polling_on: polling_date).last.id

		#get the country - first is Great Britian
			country = Country.first.id
			countryName = Country.first.name

		#pass to general_election_list_path
			visit general_election_country_show_path(generalelection, country)

		#check content on page suggests correct page?
			expect(page).to have_content("Results for the UK general election on #{polling_date_as_display}")
			expect(page).to have_content("#{countryName} - by party")
		
	end

	it 'has the same first line of results for GB for the 2024 07 04 election that was there last time' do
		#get the general election for the selected polling on date (most recent at time of writing)
			generalelection = GeneralElection.where(polling_on: polling_date).last.id


		#get the country - first is Great Britian
			country = Country.first.id
			countryName = Country.first.name


		#pass to general_election_list_path\
			visit general_election_country_show_path(generalelection, country)

			#check content on page suggests correct page?
			first_data_row = all('tbody tr').first

       		cells = first_data_row.all('td').map(&:text)

       		expect(cells).to match_array(first_line_of_results_table_gb)
		
	end

	it 'loads general-election/:general-election/countries/:country England based on 2024 07 04 GE' do
		#test the first country with a parent just to check also working
		#get the general election for the selected polling on date (most recent at time of writing)
			generalelection = GeneralElection.where(polling_on: polling_date).last.id

		#get the country - first with parent id is England
			country = Country.where(parent_country_id: '1').first.id
			countryName = Country.where(parent_country_id: '1').first.name

		#pass to general_election_list_path
			visit general_election_country_show_path(generalelection, country)

		#check content on page suggests correct page?
			expect(page).to have_content("Results for the UK general election on #{polling_date_as_display}")
			expect(page).to have_content("#{countryName} - by party")
		
	end

		it 'has the same first line of results for England for the 2024 07 04 election that was there last time' do
		#get the general election for the selected polling on date (most recent at time of writing)
			generalelection = GeneralElection.where(polling_on: polling_date).last.id


		#get the country - first with parent id is England
			country = Country.where(parent_country_id: '1').first.id
			countryName = Country.where(parent_country_id: '1').first.name


		#pass to general_election_list_path\
			visit general_election_country_show_path(generalelection, country)

			#check content on page suggests correct page?
			first_data_row = all('tbody tr').first

       		cells = first_data_row.all('td').map(&:text)

       		expect(cells).to match_array(first_line_of_results_table_en)
		
	end

end