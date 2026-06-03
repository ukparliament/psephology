require 'rails_helper'

describe "Test for checking page load /elections", type: :system do
#nothing to see here no top level variables to define

	it 'loads elections with correct first ge value' do
		#get last date of general election will follow header General Election
		ge_last_date = GeneralElection.maximum("polling_on")



		#visit election_list_path
			visit election_list_path

		#check content on page suggests correct page?
			expect(page).to have_content("General elections\n#{ge_last_date.strftime("%Y - #{ge_last_date.day} %B")}")
		
	end


	it 'loads elections with correct first byelection value for string' do
		#get last parlimentary periods with byelection (controller call parlimentary periods with by election i.e. does not create link for new period with no by elections)
		be_last_parliament_period = Election.where(general_election_id: nil).maximum("parliament_period_id")

		#get count of by elections for that period
		be_count = Election.where([general_election_id: nil, parliament_period_id: be_last_parliament_period]).count

		if be_count > 1

			be_word = 'by-elections'

		else be_word = 'by-election'

		end

			#get summoned on
		pp_summoned_on = Election.where([general_election_id: nil, parliament_period_id: be_last_parliament_period]).joins(:parliament_period).select("parliament_periods.summoned_on as summoned_on").first.summoned_on
		#format using if else as may be blank in future if staging results
		if pp_summoned_on == nil 
			pp_summoned_on = pp_summoned_on
		else pp_summoned_on = pp_summoned_on.strftime("#{pp_summoned_on.day} %B %Y")
		end

		#get dissolved on
		pp_dissolved_on = Election.where([general_election_id: nil, parliament_period_id: be_last_parliament_period]).joins(:parliament_period).select("parliament_periods.dissolved_on as dissolved_on").first.dissolved_on

		if pp_dissolved_on == nil 
			pp_dissolved_on = pp_dissolved_on
		else pp_dissolved_on = pp_dissolved_on.strftime("#{pp_dissolved_on.day} %B %Y")
		end

		#visit election_list_path
			visit election_list_path

		#check content on page suggests correct page?
			expect(page).to have_content("By-elections\n#{be_count} #{be_word} in the #{be_last_parliament_period.ordinalize} Parliament (#{pp_summoned_on} - #{pp_dissolved_on})")
		
	end

end