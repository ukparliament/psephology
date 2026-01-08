require 'rails_helper'

describe "Test that General Election pages load", type: :system do
  context "for 4th July 2024" do
    let(:polling_date)                { '2024-07-04' }
    let(:polling_date_as_link)        { '2024 - 4 July' }
    let(:polling_date_as_display)     { '4 July 2024' }
    let(:first_line_of_results_table) { ["Labour", "631", "9,708,716", "33.7%", "411"] }

    # This is using the page nav to get there
    it 'loads the general elections page and associated using navigation from the election list path' do
      visit general_election_list_path
      expect(page).to have_content("General elections")
      expect(page).to_not have_content("By-elections")

      click_on polling_date_as_link

      expect(page).to have_content("Results for the UK general election on #{polling_date_as_display}")

      first_data_row = all('table tbody tr').first

      cells = first_data_row.all('td, th').map(&:text)
      expect(cells).to match_array(first_line_of_results_table)
    end

    # This is just loading the page directly, by URL
    it 'loads a general election page directly' do
      general_election = GeneralElection.find_by(polling_on: polling_date)
      visit general_election_show_path(general_election)

      expect(page).to have_content("Results for the UK general election on #{polling_date_as_display}")
      first_data_row = all('table tbody tr').first

      cells = first_data_row.all('td, th').map(&:text)
      expect(cells).to match_array(first_line_of_results_table)
    end
  end
end



  # get 'elections' => 'election#index', as: :election_list
  # get 'elections/:election' => 'election#show', as: :election_show
  # get 'elections/:election/candidate-results' => 'election#candidate_results', as: :election_candidate_results

  # get 'general-elections' => 'general_election#index', as: :general_election_list
  # get 'general-elections/:general_election' => 'general_election#show', as: :general_election_show

