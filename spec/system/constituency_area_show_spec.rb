require 'rails_helper'

describe "Test for checking page load and data accuracy of constituency-areas/:constituency-area ", type: :system do

	#have to hard code date chosen - keeping polling date in for keeping consistency of check?
	let(:polling_date)	{("2024-07-04").to_date.strftime('%Y-%m-%d')}

	#difficult to check the majority via simple db query so hard coding no changes to be expected to data at this point
	let(:first_line_of_results_table) {[ 'Aldridge-Brownhills', 'MORTON, Wendy', '70,268', '58.2%', '15,901', '38.9%', '-30.7%', '4,294']}


	#use choosen boundary set id to then pick first 

	it 'loads constituency-areas/:constituency-area' do

		#set date conditional for boundary set - for consistency use the boundary set valid for polling date as most current set to nil
		max_boundary_set_date = BoundarySet.maximum("end_on").strftime('%Y-%m-%d')

		if max_boundary_set_date  > polling_date
			valid_boundary_set_for_polling_on = BoundarySet.where(end_on: max_boundary_set_date).first.id
		else 
			valid_boundary_set_for_polling_on = BoundarySet.where(end_on:nil).first.id
		end


	#get first constituency area using bundary_set_id
		constituencyarea = ConstituencyArea.where(boundary_set_id: valid_boundary_set_for_polling_on).first.id

	#get the name which matches this id
		constituencyareaName = ConstituencyArea.where([boundary_set_id: valid_boundary_set_for_polling_on, id: constituencyarea]).first.name
	
	#get the start on date - this comes from boundary set table have not joined as using id already
		constituencyareaStartOn = BoundarySet.where(id: valid_boundary_set_for_polling_on).first.start_on
		#format
		constituencyareaStartOn = constituencyareaStartOn.strftime('%d %B %Y')

	#get the end on date - this comes from boundary set table have not joined as using id already
		constituencyareaEndOn = BoundarySet.where(id: valid_boundary_set_for_polling_on).first.end_on
		#format have to use if because end_on can be nil
		if constituencyareaEndOn == nil 
			constituencyareaEndOn = constituencyareaEndOn
		else 
			constituencyareaEndOn = constituencyareaEndOn.strftime('%d %B %Y')
		end


		#pass to general_election_list_path
			visit constituency_area_show_path(constituencyarea)

		#check content on page suggests correct page?
			expect(page).to have_content("#{constituencyareaName} (#{constituencyareaStartOn} - #{constituencyareaEndOn})")
			
		
	end

end