Rails.application.routes.draw do
  resources :rooms, only: [:create, :show, :update] do
    resources :guesses, only: [:create, :new, :show]
    resources :players, only: [:create, :new]
  end
  root to: 'rooms#create'
end
