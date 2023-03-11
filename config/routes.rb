Rails.application.routes.draw do
  resources :sleep_records, only: [:create, :show]
end
