Rails.application.routes.draw do
  devise_for :users

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  authenticated :user do
    root "dashboard#show", as: :authenticated_root
  end
  root "home#index"

  resources :analyses, only: [:create, :show] do
    collection do
      post :demo # явный эндпоинт под демо-анализ
    end
  end

  resources :sessions, only: :create
end
