Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"
  
  get '/' => 'home#index', as: :home
  
  get 'elections' => 'election#index', as: :election_list
  get 'elections/:election' => 'election#show', as: :election_show
  get 'elections/:election/candidate-results' => 'election#candidate_results', as: :election_candidate_results
  
  get 'general-elections' => 'general_election#index', as: :general_election_list
  get 'general-elections/:general_election' => 'general_election#show', as: :general_election_show
  
  get 'general-elections/:general_election/candidacies' => 'general_election_candidacy#index', as: :general_election_candidacy_list
  
  get 'general-elections/:general_election/elections' => 'general_election_election#index', as: :general_election_election_list
  
  get 'general-elections/:general_election/constituency-areas' => 'general_election_constituency_area#index', as: :general_election_constituency_area_list
  
  get 'general-elections/:general_election/map' => 'general_election_map#index', as: :general_election_map
  
  get 'general-elections/:general_election/majority' => 'general_election_majority#index', as: :general_election_majority_list
  
  get 'general-elections/:general_election/vote-share' => 'general_election_vote_share#index', as: :general_election_vote_share_list
  
  get 'general-elections/:general_election/turnout' => 'general_election_turnout#index', as: :general_election_turnout_list
  
  get 'general-elections/:general_election/declaration-times' => 'general_election_declaration_times#index', as: :general_election_declaration_time_list
  
  get 'general-elections/:general_election/political-parties' => 'general_election_party#index', as: :general_election_party_list
  get 'general-elections/:general_election/political-parties/:political_party' => 'general_election_party#show', as: :general_election_party_show
  
  get 'general-elections/:general_election/political-parties/:political_party/elections' => 'general_election_party_election#index', as: :general_election_party_election_list
  get 'general-elections/:general_election/political-parties/:political_party/elections/won' => 'general_election_party_election#won', as: :general_election_party_election_won
  
  get 'general-elections/:general_election/uncertified-candidacies' => 'general_election_uncertified_candidacy#index', as: :general_election_uncertified_candidacy_list
  
  get 'general-elections/:general_election/boundary-sets' => 'general_election_boundary_set#index', as: :general_election_boundary_set_list
  
  
  get 'general-elections/:general_election/countries' => 'general_election_country#index', as: :general_election_country_list
  get 'general-elections/:general_election/countries/:country' => 'general_election_country#show', as: :general_election_country_show
  
  get 'general-elections/:general_election/countries/:country/candidacies' => 'general_election_country_candidacy#index', as: :general_election_country_candidacy_list
  
  get 'general-elections/:general_election/countries/:country/elections' => 'general_election_country_election#index', as: :general_election_country_election_list
  
  get 'general-elections/:general_election/countries/:country/constituency-areas' => 'general_election_country_constituency_area#index', as: :general_election_country_constituency_area_list
  
  get 'general-elections/:general_election/countries/:country/majority' => 'general_election_country_majority#index', as: :general_election_country_majority_list
  
  get 'general-elections/:general_election/countries/:country/vote-share' => 'general_election_country_vote_share#index', as: :general_election_country_vote_share_list
  
  get 'general-elections/:general_election/countries/:country/turnout' => 'general_election_country_turnout#index', as: :general_election_country_turnout_list
  
  get 'general-elections/:general_election/countries/:country/declaration-times' => 'general_election_country_declaration_time#index', as: :general_election_country_declaration_time_list
  
  get 'general-elections/:general_election/countries/:country/political-parties' => 'general_election_country_political_party#index', as: :general_election_country_political_party_list
  get 'general-elections/:general_election/countries/:country/political-parties/:political_party' => 'general_election_country_political_party#show', as: :general_election_country_political_party_show
  
  get 'general-elections/:general_election/countries/:country/political-parties/:political_party/elections' => 'general_election_country_party_election#index', as: :general_election_country_party_election_list
  get 'general-elections/:general_election/countries/:country/political-parties/:political_party/elections/won' => 'general_election_country_party_election#won', as: :general_election_country_party_election_won
  
  get 'general-elections/:general_election/countries/:country/uncertified-candidacies' => 'general_election_country_uncertified_candidacy#index', as: :general_election_country_uncertified_candidacy_list
  
  
  get 'general-elections/:general_election/countries/:country/english-regions' => 'general_election_english_region#index', as: :general_election_english_region_list
  get 'general-elections/:general_election/countries/:country/english-regions/:english_region' => 'general_election_english_region#show', as: :general_election_english_region_show
  
  get 'general-elections/:general_election/countries/:country/english-regions/:english_region/candidacies' => 'general_election_english_region_candidacy#index', as: :general_election_english_region_candidacy_list
  
  get 'general-elections/:general_election/countries/:country/english-regions/:english_region/constituency-areas' => 'general_election_english_region_constituency_area#index', as: :general_election_english_region_constituency_area_list
  
  get 'general-elections/:general_election/countries/:country/english-regions/:english_region/majority' => 'general_election_english_region_majority#index', as: :general_election_english_region_majority_list
  
  get 'general-elections/:general_election/countries/:country/english-regions/:english_region/vote-share' => 'general_election_english_region_vote_share#index', as: :general_election_english_region_vote_share_list
  
  get 'general-elections/:general_election/countries/:country/english-regions/:english_region/turnout' => 'general_election_english_region_turnout#index', as: :general_election_english_region_turnout_list
  
  get 'general-elections/:general_election/countries/:country/english-regions/:english_region/declaration-times' => 'general_election_english_region_declaration_time#index', as: :general_election_english_region_declaration_time_list
  
  get 'general-elections/:general_election/countries/:country/english-regions/:english_region/political-parties' => 'general_election_english_region_political_party#index', as: :general_election_english_region_political_party_list
  get 'general-elections/:general_election/countries/:country/english-regions/:english_region/political-parties/:political_party' => 'general_election_english_region_political_party#show', as: :general_election_english_region_political_party_show
  
  get 'general-elections/:general_election/countries/:country/english-regions/:english_region/political-parties/:political_party/elections' => 'general_election_english_region_party_election#index', as: :general_election_english_region_party_election_list
  get 'general-elections/:general_election/countries/:country/english-regions/:english_region/political-parties/:political_party/elections/won' => 'general_election_english_region_party_election#won', as: :general_election_english_region_party_election_won
  
  get 'general-elections/:general_election/countries/:country/english-regions/:english_region/uncertified-candidacies' => 'general_election_english_region_uncertified_candidacy#index', as: :general_election_english_region_uncertified_candidacy_list
  
  get 'constituency-areas' => 'constituency_area#index', as: :constituency_area_list
  get 'constituency-areas/current' => 'constituency_area#current', as: :constituency_area_list_current
  get 'constituency-areas/all' => 'constituency_area#all', as: :constituency_area_list_all
  get 'constituency-areas/:constituency_area' => 'constituency_area#show', as: :constituency_area_show
  
  get 'constituency-areas/:constituency_area/elections' => 'constituency_area_election#index', as: :constituency_area_election_list
  
  get 'constituency-areas/:constituency_area/maiden-speeches' => 'constituency_area_maiden_speech#index', as: :constituency_area_maiden_speech_list
  
  get 'constituency-areas/:constituency_area/overlaps' => 'constituency_area_overlap#show', as: :constituency_area_overlap_show
  
  get 'constituency-area-overlaps' => 'constituency_area_overlap#index', as: :constituency_area_overlap_list
  
  get 'constituency-areas/current/countries' => 'constituency_area_country#index', as: :constituency_area_country_list
  get 'constituency-areas/current/countries/:country' => 'constituency_area_country#show', as: :constituency_area_country_show
  
  get 'constituency-areas/current/countries/:country/english-regions' => 'constituency_area_english_region#index', as: :constituency_area_english_region_index
  get 'constituency-areas/current/countries/:country/english-regions/:english_region' => 'constituency_area_english_region#show', as: :constituency_area_english_region_show
  
  get 'political-parties' => 'political_party#index', as: :political_party_list
  get 'political-parties/winning' => 'political_party#winning', as: :political_party_winning_list
  get 'political-parties/fall' => 'political_party#fall', as: :political_party_fall
  get 'political-parties/:political_party' => 'political_party#show', as: :political_party_show
  
  get 'political-parties/:political_party/general-elections' => 'political_party_general_election#index', as: :political_party_general_election_list
  
  get 'political-parties/:political_party/by-elections' => 'political_party_by_election#index', as: :political_party_by_election_list
  
  get 'political-parties/:political_party/by-elections/parliament-periods' => 'political_party_by_election_parliament_period#index', as: :political_party_by_election_parliament_period_list
  get 'political-parties/:political_party/by-elections/parliament-periods/:parliament_period' => 'political_party_by_election_parliament_period#show', as: :political_party_by_election_parliament_period_show
  
  get 'political-parties/:political_party/registrations' => 'political_party_party_registration#index', as: :political_party_party_registration_list
  
  get 'political-party-registrations' => 'political_party_registration#index', as: :political_party_registration_list
  
  get 'members/a-z' => 'member_a_to_z#index', as: :member_a_to_z_list
  get 'members/a-z/:letter' => 'member_a_to_z#show', as: :member_a_to_z_show
  
  get 'members' => 'member#index', as: :member_list
  get 'members/:member' => 'member#show', as: :member_show
  
  get 'members/:member/elections' => 'member_election#index', as: :member_election_list
  get 'members/:member/elections/won' => 'member_election#won', as: :member_election_won
  
  get 'parliament-periods' => 'parliament_period#index', as: :parliament_period_list
  get 'parliament-periods/:parliament_period' => 'parliament_period#show', as: :parliament_period_show
  
  get 'parliament-periods/:parliament_period/by-elections' => 'parliament_period_by_election#index', as: :parliament_period_by_election_list
  
  get 'parliament-periods/:parliament_period/boundary-sets' => 'parliament_period_boundary_set#index', as: :parliament_period_boundary_set_list
  
  get 'parliament-periods/:parliament_period/maiden-speeches' => 'parliament_period_maiden_speech#index', as: :parliament_period_maiden_speech_list
  
  get 'boundary-sets' => 'boundary_set#index', as: :boundary_set_list
  get 'boundary-sets/:boundary_set' => 'boundary_set#show', as: :boundary_set_show
  
  get 'boundary-sets/:boundary_set/constituency-areas' => 'boundary_set_constituency_area#index', as: :boundary_set_constituency_area_list
  
  get 'boundary-sets/:boundary_set/legislation-items' => 'boundary_set_legislation_item#index', as: :boundary_set_legislation_item_list
  
  get 'boundary-sets/:boundary_set/general-elections' => 'boundary_set_general_election#index', as: :boundary_set_general_election_list
  
  get 'boundary-sets/:boundary_set/by-elections' => 'boundary_set_by_election#index', as: :boundary_set_by_election_list
  
  get 'boundary-sets/:boundary_set/majority' => 'boundary_set_general_election_majority#index', as: :boundary_set_general_election_majority_list
  
  get 'boundary-sets/:boundary_set/vote-share' => 'boundary_set_general_election_vote_share#index', as: :boundary_set_general_election_vote_share_list
  
  get 'boundary-sets/:boundary_set/turnout' => 'boundary_set_general_election_turnout#index', as: :boundary_set_general_election_turnout_list
  
  get 'boundary-sets/:boundary_set/parties' => 'boundary_set_general_election_party#index', as: :boundary_set_general_election_party_list
  
  get 'countries' => 'country#index', as: :country_list
  get 'countries/:country' => 'country#show', as: :country_show
  
  get 'countries/:country/boundary-sets' => 'country_boundary_set#index', as: :country_boundary_set_list
  
  get 'legislation-items' => 'legislation_item#index', as: :legislation_item_list
  get 'legislation-items/:legislation_item' => 'legislation_item#show', as: :legislation_item_show
  
  get 'legislation-items/:legislation_item/boundary-sets' => 'legislation_item_boundary_set#index', as: :legislation_item_boundary_set_list
  
  get 'legislation-items/:legislation_item/enabled-legislation' => 'legislation_item_enabled_legislation#index', as: :legislation_item_enabled_legislation_list
  
  get 'legislation-items/:legislation_item/enabling-legislation' => 'legislation_item_enabling_legislation#index', as: :legislation_item_enabling_legislation_list
  
  get 'acts-of-parliament' => 'act_of_parliament#index', as: :act_of_parliament_list
  
  get 'orders-in-council' => 'order_in_council#index', as: :order_in_council_list
  
  get 'meta' => 'meta#index', as: :meta_list
  get 'meta/coverage' => 'meta#coverage', as: :meta_coverage
  get 'meta/roadmap' => 'meta#roadmap', as: :meta_roadmap
  get 'meta/contact' => 'meta#contact', as: :meta_contact
  get 'meta/cookies' => 'meta#cookies', as: :meta_cookies
  get 'meta/schema' => 'meta#schema', as: :meta_schema
  get 'meta/data-dictionary' => 'meta#data_dictionary', as: :meta_data_dictionary

  # ## Redirect from old election result website constituency results URLs.
  
  # ### 301s
  get 'About' => 'redirect#coverage'
  
  get 'election/:polling_on/Results/Location/Constituency/:constituency' => 'redirect#election'
  get 'election/:polling_on/Results/Location/constituency/:constituency' => 'redirect#election'
  get 'election/:polling_on/Results/location/Constituency/:constituency' => 'redirect#election'
  get 'election/:polling_on/results/Location/Constituency/:constituency' => 'redirect#election'
  get 'election/:polling_on/results/location/Constituency/:constituency' => 'redirect#election'
  get 'election/:polling_on/results/Location/constituency/:constituency' => 'redirect#election'
  get 'election/:polling_on/Results/location/constituency/:constituency' => 'redirect#election'
  get 'election/:polling_on/results/location/constituency/:constituency' => 'redirect#election'
  
  get 'election/:polling_on/Results/Location/Country/United Kingdom' => 'redirect#general_election_country_uk'
  get 'election/:polling_on/Results/Location/country/United Kingdom' => 'redirect#general_election_country_uk'
  get 'election/:polling_on/Results/location/Country/United Kingdom' => 'redirect#general_election_country_uk'
  get 'election/:polling_on/results/Location/Country/United Kingdom' => 'redirect#general_election_country_uk'
  get 'election/:polling_on/results/location/Country/United Kingdom' => 'redirect#general_election_country_uk'
  get 'election/:polling_on/results/Location/country/United Kingdom' => 'redirect#general_election_country_uk'
  get 'election/:polling_on/Results/location/country/United Kingdom' => 'redirect#general_election_country_uk'
  get 'election/:polling_on/results/location/country/United Kingdom' => 'redirect#general_election_country_uk'
  
  get 'election/:polling_on/Results/Location/Country/:country' => 'redirect#general_election_country'
  get 'election/:polling_on/Results/Location/country/:country' => 'redirect#general_election_country'
  get 'election/:polling_on/Results/location/Country/:country' => 'redirect#general_election_country'
  get 'election/:polling_on/results/Location/Country/:country' => 'redirect#general_election_country'
  get 'election/:polling_on/results/location/Country/:country' => 'redirect#general_election_country'
  get 'election/:polling_on/results/Location/country/:country' => 'redirect#general_election_country'
  get 'election/:polling_on/Results/location/country/:country' => 'redirect#general_election_country'
  get 'election/:polling_on/results/location/country/:country' => 'redirect#general_election_country'
  
  get 'election/:polling_on/Results/Location/Region/:region' => 'redirect#general_election_region'
  get 'election/:polling_on/Results/Location/region/:region' => 'redirect#general_election_region'
  get 'election/:polling_on/Results/location/Region/:region' => 'redirect#general_election_region'
  get 'election/:polling_on/results/Location/Region/:region' => 'redirect#general_election_region'
  get 'election/:polling_on/results/location/Region/:region' => 'redirect#general_election_region'
  get 'election/:polling_on/results/Location/region/:region' => 'redirect#general_election_region'
  get 'election/:polling_on/Results/location/region/:region' => 'redirect#general_election_region'
  get 'election/:polling_on/results/location/region/:region' => 'redirect#general_election_region'
  
  get 'election/:polling_on/Statistics/Majority' => 'redirect#general_election_majority'
  get 'election/:polling_on/Statistics/majority' => 'redirect#general_election_majority'
  get 'election/:polling_on/statistics/Majority' => 'redirect#general_election_majority'
  get 'election/:polling_on/statistics/majority' => 'redirect#general_election_majority'
  
  get 'election/:polling_on/Statistics/Turnout' => 'redirect#general_election_turnout'
  get 'election/:polling_on/Statistics/turnout' => 'redirect#general_election_turnout'
  get 'election/:polling_on/statistics/Turnout' => 'redirect#general_election_turnout'
  get 'election/:polling_on/statistics/turnout' => 'redirect#general_election_turnout'
  
  get 'election/:polling_on/Results/Party/:party' => 'redirect#general_election_party'
  get 'election/:polling_on/Results/party/:party' => 'redirect#general_election_party'
  get 'election/:polling_on/results/Party/:party' => 'redirect#general_election_party'
  get 'election/:polling_on/results/party/:party' => 'redirect#general_election_party'
  
  # ### 303s
  
  get 'election/:polling_on/Search' => 'redirect#general_election_see_also'
  
  get 'election/:polling_on/Results/Location/County/:county' => 'redirect#general_election_see_also'
  get 'election/:polling_on/Results/Location/county/:county' => 'redirect#general_election_see_also'
  get 'election/:polling_on/Results/location/County/:county' => 'redirect#general_election_see_also'
  get 'election/:polling_on/results/Location/County/:county' => 'redirect#general_election_see_also'
  get 'election/:polling_on/results/location/County/:county' => 'redirect#general_election_see_also'
  get 'election/:polling_on/results/Location/county/:county' => 'redirect#general_election_see_also'
  get 'election/:polling_on/Results/location/county/:county' => 'redirect#general_election_see_also'
  get 'election/:polling_on/results/location/county/:county' => 'redirect#general_election_see_also'
  
  get 'election/:polling_on/Statistics/Candidates' => 'redirect#general_election_see_also'
  get 'election/:polling_on/Statistics/candidates' => 'redirect#general_election_see_also'
  get 'election/:polling_on/statistics/Candidates' => 'redirect#general_election_see_also'
  get 'election/:polling_on/statistics/candidates' => 'redirect#general_election_see_also'
end
