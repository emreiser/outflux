Outflux::Application.routes.draw do
 resources :refugee_counts, only: [:index, :create]
 root to: 'refugee_counts#index'

 get '/:code/:year' => 'refugee_counts#index'
end
