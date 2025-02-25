Rails.application.routes.draw do
  resources :search_songs, only: [ :index, :show, :create, :destroy ] do
    collection do
      get :search_results
      get :how_to_use
      get :lyrics
    end
    member do
    end
  end
  root "search_songs#index"
end
