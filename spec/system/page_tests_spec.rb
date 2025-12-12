require 'rails_helper'
require 'support/database_support'

describe "page tests", type: :system do
  # This does it once before running all the tests in this file
  before(:context) do
    load_sql_dump
  end

  # And afterwards, will truncate test database tables
  after(:context) do
    truncate_all_data_tables
  end

  it 'home page loads' do
    visit root_path
    expect(page).to have_content("UK Parliament House of Commons Library Election Results")
  end

  it 'elections page and associated load' do
    visit election_list_path
    expect(page).to have_content("General elections")
    expect(page).to have_content("By-elections")

    click_on '2024 - 4 July'

    expect(page).to have_content("Results for the UK general election on 4 July 2024")

    first_data_row = all('table tbody tr').first

    cells = first_data_row.all('td, th').map(&:text)
    expect(cells).to match_array(["Labour", "631", "9,708,716", "33.7%", "411"])
  end
end
