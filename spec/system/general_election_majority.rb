require 'rails_helper'

describe "Test that the full candidates and constituencies are present on general-election/:general-election/majority", type: :system do
	context "For polling date 4th July 2024" do

	let(:polling_date)	{'2024-07-04'}
	let(:polling_date_as_display)     { '4 July 2024' }
	let (:first_line_of_results_table)  {['Chorley','HOYLE, Lindsay','Spk','33,964','20,575','60.6%'] }



		it "loads general-election/:general-election/majority page and expected text appears" do

			#get the general election for the selected polling on date (most recent at time of writing)
			generalelection = GeneralElection.where(polling_on: polling_date).last.id

			#pass to general_election_list_path
			visit general_election_majority_list_path(generalelection)

			#check content on page suggests correct page?
			expect(page).to have_content("Results for the UK general election on #{polling_date_as_display}")
			expect(page).to have_content("By majority")


			#check message outline
			parliament_period = Election.joins(:electorate).where(polling_on: polling_date).last.parliament_period_id

			electorate = Election.joins(:electorate).where(polling_on: polling_date).sum(:population_count)
			electorate_formatted = electorate.to_fs(:delimited)

			total_valid_vote_count = Election.where(polling_on: polling_date).sum(:valid_vote_count)
			total_valid_vote_count_formatted = total_valid_vote_count.to_fs(:delimited)

			total_invalid_vote_count = Election.where(polling_on: polling_date).sum(:invalid_vote_count)
			total_invalid_vote_count_formatted = total_invalid_vote_count.to_fs(:delimited)


			expect(page).to have_content("A general election to the #{parliament_period}th Parliament of the United Kingdom with an electorate of #{electorate_formatted}, having #{total_valid_vote_count_formatted} valid votes and #{total_invalid_vote_count_formatted} invalid votes")
		#A general election to the 59th Parliament of the United Kingdom with an electorate of 48,224,212, having 28,809,340 valid votes and 116,253 invalid votes.

		end

		#check loaded data, had to hard code assuming this will not change in future
		it "loads first line of data matching the previous live version of general-election/:general-election/majorities" do 
			#get the general election for the selected polling on date (most recent at time of writing)
			generalelection = GeneralElection.where(polling_on: polling_date).last.id

			#pass to general_election_list_path
			visit general_election_majority_list_path(generalelection)

			first_data_row = all('tbody tr').first

       		cells = first_data_row.all('td').map(&:text)

       		expect(cells).to match_array(first_line_of_results_table)

       	end

       	#idea to count number output??


	end
end