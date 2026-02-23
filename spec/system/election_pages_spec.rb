require 'rails_helper'

describe "Test that Election pages load", type: :system do

  # get 'elections' => 'election#index', as: :election_list
  it 'loads the elections page' do
    visit election_list_path
    expect(page).to have_content("General elections")
    expect(page).to have_content("By-elections")
  end

  # get 'elections/:election' => 'election#show', as: :election_show
  it 'loads an election page' do
    election = Election.includes(:constituency_group).order(id: :desc).last

    visit election_show_path(election)
    expect(page).to have_content(election.constituency_group.name)
  end

  # get 'elections/:election/candidate-results' => 'election#candidate_results', as: :election_candidate_results
  it 'loads an election page with candidate results' do
    election = Election.includes(:constituency_group).order(id: :desc).last

    visit election_candidate_results_path(election)
    expect(page).to have_content(election.constituency_group.name)
    expect(page).to have_content("Candidates")
  end
end
