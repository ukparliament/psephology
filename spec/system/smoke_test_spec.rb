require 'rails_helper'

describe "smoke test", type: :system do

  # We don't have any javascript, so can just use rack test
  before do
    driven_by(:rack_test)
  end

  it 'home page loads' do
    visit root_path
    expect(page).to have_content("UK Parliament House of Commons Library Election Results")
  end
end
