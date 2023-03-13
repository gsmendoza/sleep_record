Rails.application.routes.draw do
  resources :sleep_records, only: [:create, :show, :index] do
    member do
      patch :clock_out
    end
  end
end
