Rails.application.routes.draw do
  resources :rooms, only: [:create, :show, :update] do
    resources :guesses, only: :create
    resources :players, only: :create
  end
  root to: 'rooms#create'
end
