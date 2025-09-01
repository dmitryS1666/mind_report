Rails.application.routes.draw do
  devise_for :users

  root "dashboard#show"
  resource :dashboard, only: :show
  resources :analyses, only: [:create, :show] do
    collection do
      post :demo
      delete :clear_history
    end
  end
  resources :sessions, only: :create

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
