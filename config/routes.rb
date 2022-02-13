Rails.application.routes.draw do
  resources :rooms, only: :create
  get '/rooms/:id', to: 'rooms#show', as: :room
  post '/rooms/:id/guess', to: 'rooms#guess', as: :room_guess
  get '/rooms/:id/reset', to: 'rooms#reset', as: :room_reset

  root to: 'rooms#create'
end
