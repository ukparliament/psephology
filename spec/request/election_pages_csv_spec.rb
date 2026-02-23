require 'rails_helper'

describe "CSV Test that Election pages load", type: :request do

  # get 'elections' => 'election#index', as: :election_list
  it 'downloads the elections in CSV format' do
    get election_list_path(format: :csv)

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to match(/text\/csv/)
    expect(response.headers['Content-Disposition']).to include('attachment')

    # Parse and verify CSV content
    csv = CSV.parse(response.body)
    expect(csv.length).to be > 1
    expect(csv.first).to match_array(ElectionController::ELECTIONS_INDEX_CSV_HEADER.split(',')) # headers
  end

  # get 'elections/:election' => 'election#show', as: :election_show
  it 'downloads a single election csv' do
    pending("There is no CSV endpoint for this at the moment")
    fail
  end

  # get 'elections/:election/candidate-results' => 'election#candidate_results', as: :election_candidate_results
  it 'downloads an election page with candidate results in CSV format' do
    election = Election.includes(:constituency_group).order(id: :desc).last

    get election_candidate_results_path(election, format: :csv)

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to match(/text\/csv/)
    expect(response.headers['Content-Disposition']).to include('attachment')

    # Parse and verify CSV content
    csv = CSV.parse(response.body)
    expect(csv.length).to be > 1
    expect(csv.first).to match_array(ElectionController::CANDIDATE_RESULTS_CSV_HEADER.split(',')) # headers
  end
end
