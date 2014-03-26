Outflux::Application.routes.draw do
 resources :refugee_counts, only: [:index, :create]
 root to: 'refugee_counts#index'

 get '/:code/:year', to: 'refugee_counts#index', as: 'country_year'
end
