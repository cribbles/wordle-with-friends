Rails.application.routes.draw do
  resources :rooms, only: %i[show create reset] do
    post :guess
  end

  root to: 'rooms#create'
end
