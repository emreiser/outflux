Outflux::Application.routes.draw do
 resources :refugee_counts, only: [:index, :create]
 resources :stories, only: [:index]
 root to: 'refugee_counts#index'

 get '/:code/:year', to: 'refugee_counts#index', as: 'country_year'
end
