Rails.application.routes.draw do
  resources :sleep_records, only: [:create, :show, :index] do
    collection do
      get :friend
    end

    member do
      patch :clock_out
    end
  end

  resources :follow_relationships, only: [:create, :show, :destroy]
end
