Rails.application.routes.draw do
  resources :rooms, only: :create
  get '/rooms/:name', to: 'rooms#show', as: :room
  post '/rooms/:name/guess', to: 'rooms#guess', as: :room_guess
  get '/rooms/:name/reset', to: 'rooms#reset', as: :room_reset

  root to: 'rooms#create'
end
