Rails.application.routes.draw do
  get 'game', to: 'play#game', as: :game


  get 'score', to: 'play#score', as: :score

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
