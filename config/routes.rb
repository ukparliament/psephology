Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  
  get '/' => 'home#index', as: :root
  get 'psephology' => 'home#index', as: :home
  
  get 'psephology/elections' => 'election#index', as: :election_list
  get 'psephology/elections/:election' => 'election#show', as: :election_show
  get 'psephology/elections/:election/candidacies' => 'election#candidacies', as: :election_candidacies
  get 'psephology/elections/:election/results' => 'election#results', as: :election_results
  get 'psephology/elections/:election/results/candidacies' => 'election#results_candidacies', as: :election_results_candidacies
  
  get 'psephology/members' => 'member#index', as: :member_list
  get 'psephology/members/:member' => 'member#show', as: :member_show
  
  get 'psephology/general-elections' => 'general_election#index', as: :general_election_list
  get 'psephology/general-elections/:general_election' => 'general_election#show', as: :general_election_show
  
  get 'psephology/general-elections/:general_election/majority' => 'general_election_majority#index', as: :general_election_majority_list
  
  get 'psephology/general-elections/:general_election/turnout' => 'general_election_turnout#index', as: :general_election_turnout_list
  
  get 'psephology/general-elections/:general_election/declaration-time' => 'general_election_declaration#index', as: :general_election_declaration_list
  
  get 'psephology/general-elections/:general_election/vote-share' => 'general_election_vote_share#index', as: :general_election_vote_share_list
  
  get 'psephology/general-elections/:general_election/parties' => 'general_election_party#index', as: :general_election_party_list
  
  get 'psephology/by-elections' => 'by_election#index', as: :by_election_list
  
  get 'psephology/parliament-periods' => 'parliament_period#index', as: :parliament_period_list
  get 'psephology/parliament-periods/:parliament_period' => 'parliament_period#show', as: :parliament_period_show
  
  get 'psephology/general-elections/:general_election/countries' => 'general_election_country#index', as: :general_election_country_list
  get 'psephology/general-elections/:general_election/countries/:country' => 'general_election_country#show', as: :general_election_country_show
  
  get 'psephology/general-elections/:general_election/countries/:country/english-regions' => 'general_election_english_region#index', as: :general_election_english_region_list
  get 'psephology/general-elections/:general_election/countries/:country/english-regions/:english_region' => 'general_election_english_region#show', as: :general_election_english_region_show
  
  get 'psephology/legislation-items' => 'legislation_item#index', as: :legislation_item_list
  get 'psephology/legislation-items/:legislation_item' => 'legislation_item#show', as: :legislation_item_show
  
  get 'psephology/orders-in-council' => 'order_in_council#index', as: :order_in_council_list
  
  get 'psephology/acts-of-parliament' => 'act_of_parliament#index', as: :act_of_parliament_list
  
  get 'psephology/countries' => 'country#index', as: :country_list
  get 'psephology/countries/:country' => 'country#show', as: :country_show
  
  get 'psephology/countries/:country/boundary-sets' => 'country_boundary_set#index', as: :country_boundary_set_list
  get 'psephology/countries/:country/boundary-sets/:boundary_set' => 'country_boundary_set#show', as: :country_boundary_set_show
  
  get 'psephology/countries/:country/boundary-sets/:boundary_set/party-switches' => 'country_boundary_party_switch#index', as: :country_boundary_set_party_switch_list
  
  get 'psephology/countries/:country/boundary-sets/:boundary_set/general-elections' => 'country_boundary_set_general_election#index', as: :country_boundary_set_general_election_list
  get 'psephology/countries/:country/boundary-sets/:boundary_set/general-elections/majority' => 'country_boundary_set_general_election#majority', as: :country_boundary_set_general_election_majority
  get 'psephology/countries/:country/boundary-sets/:boundary_set/general-elections/majority/long' => 'country_boundary_set_general_election#majority_long', as: :country_boundary_set_general_election_majority_long
  get 'psephology/countries/:country/boundary-sets/:boundary_set/general-elections/turnout' => 'country_boundary_set_general_election#turnout', as: :country_boundary_set_general_election_turnout
  
  get 'psephology/boundary-sets' => 'boundary_set#index', as: :boundary_set_list
  
  get 'psephology/constituency-areas' => 'constituency_area#index', as: :constituency_area_list
  get 'psephology/constituency-areas/current' => 'constituency_area#current', as: :constituency_area_list_current
  get 'psephology/constituency-areas/all' => 'constituency_area#all', as: :constituency_area_list_all
  get 'psephology/constituency-areas/:constituency_area' => 'constituency_area#show', as: :constituency_area_show
  
  get 'psephology/political-parties' => 'political_party#index', as: :political_party_list
  get 'psephology/political-parties/fall' => 'political_party#fall', as: :political_party_fall
  get 'psephology/political-parties/:political_party' => 'political_party#show', as: :political_party_show
  
  get 'psephology/meta' => 'meta#index', as: :meta_list
  get 'psephology/meta/about' => 'meta#about', as: :meta_about
  get 'psephology/meta/schema' => 'meta#schema', as: :meta_schema
end
