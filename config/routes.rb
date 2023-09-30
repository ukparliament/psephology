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
  
  get 'psephology/general-elections' => 'general_election#index', as: :general_election_list
  get 'psephology/general-elections/:general_election' => 'general_election#show', as: :general_election_show
  
  get 'psephology/by-elections' => 'by_election#index', as: :by_election_list
  get 'psephology/by-elections/:by_election' => 'by_election#show', as: :by_election_show
  
  get 'psephology/general-elections/:general_election/countries' => 'general_election_country#index', as: :general_election_country_list
  get 'psephology/general-elections/:general_election/countries/:country' => 'general_election_country#show', as: :general_election_country_show
  
  get 'psephology/general-elections/:general_election/countries/:country/english-regions' => 'general_election_english_region#index', as: :general_election_english_region_list
  get 'psephology/general-elections/:general_election/countries/:country/english-regions/:english_region' => 'general_election_english_region#show', as: :general_election_english_region_show
  
  get 'psephology/orders-in-council' => 'order_in_council#index', as: :order_in_council_list
  get 'psephology/orders-in-council/:order_in_council' => 'order_in_council#show', as: :order_in_council_show
  
  get 'psephology/boundary-sets' => 'boundary_set#index', as: :boundary_set_list
  get 'psephology/boundary-sets/:boundary_set' => 'boundary_set#show', as: :boundary_set_show
  
  get 'psephology/constituency-areas' => 'constituency_area#index', as: :constituency_area_list
  get 'psephology/constituency-areas/current' => 'constituency_area#current', as: :constituency_area_list_current
  get 'psephology/constituency-areas/all' => 'constituency_area#all', as: :constituency_area_list_all
  get 'psephology/constituency-areas/:constituency_area' => 'constituency_area#show', as: :constituency_area_show
end
