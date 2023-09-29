Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  
  get '/' => 'home#index', as: :root
  get 'psephology' => 'home#index', as: :home
  
  get 'psephology/general-elections' => 'general_election#index', as: :general_election_list
  get 'psephology/general-elections/:general_election' => 'general_election#show', as: :general_election_show
  
  get 'psephology/orders-in-council' => 'order_in_council#index', as: :order_in_council_list
  get 'psephology/orders-in-council/:order_in_council' => 'order_in_council#show', as: :order_in_council_show
  
  get 'psephology/boundary-sets' => 'boundary_set#index', as: :boundary_set_list
  get 'psephology/boundary-sets/:boundary_set' => 'boundary_set#show', as: :boundary_set_show
  
  get 'psephology/constituency-areas' => 'constituency_area#index', as: :constituency_area_list
  get 'psephology/constituency-areas/current' => 'constituency_area#current', as: :constituency_area_list_current
  get 'psephology/constituency-areas/all' => 'constituency_area#all', as: :constituency_area_list_all
  get 'psephology/constituency-areas/:constituency_area' => 'constituency_area#show', as: :constituency_area_show
end
