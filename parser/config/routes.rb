Rails.application.routes.draw do
  
  namespace :api do
    namespace :v1, defaults: {format: :json} do 
      resources :parse, only: [:create]
      resources :health_check, only: [:index]
      resources :check_non_delivered, only: [:index]
    end  
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
