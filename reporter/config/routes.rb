Rails.application.routes.draw do

  namespace :api do
    namespace :v1, defaults: {format: :json} do 
      resources :report_by_entry, only: [:show]
      resources :report_by_document, only: [:show]
      resources :health_check, only: [:index]
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
