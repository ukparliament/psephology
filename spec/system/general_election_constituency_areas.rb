require 'rails_helper'

	describe 'Test to load general_election/:general_election/constituency-areas', type: :system do
	context 'for 4th July 2024' do
			let(:polling_date){ '2024-07-04' }
			let(:polling_date_as_link)        { '2024 - 4 July' }


		# get general_election_constituency_area#index
		it 'loads the general election constituency areas page' do
			generalelection = GeneralElection.where(polling_on: polling_date).last.id
			
			visit general_election_constituency_area_list_path(generalelection)

		end

		# check this is the right page, Rachel confused herself
		it 'is using the correct url in navigation' do
			generalelection = GeneralElection.where(polling_on: polling_date).last.id

			visit general_election_list_path 

			click_on polling_date_as_link

			click_on 'Constituencies'

			expect(current_path).to eql general_election_constituency_area_list_path(generalelection)

		end


		#check both the countries load, Great Britian and Northern Ireland
		it 'loads both the countries' do
			#have to reload the page as does not contain context from prior test
			#generalelection = GeneralElection.where(polling_on: polling_date).last.id
			
			#general_election_constituency_area_list_path(generalelection)

			visit general_election_list_path 

			click_on polling_date_as_link

			click_on 'Constituencies'


			#query to return array of names of countries at top level (i.e. no parent) and not Ireland
			firstlevelcountries = Country.where.not(geographic_code: nil).where(parent_country_id: nil).pluck(:name).first

			#check high level countries are there
			expect(page).to have_content(firstlevelcountries)
		end
	end
end

