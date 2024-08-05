Rails.application.routes.draw do
  scope "(:locale)", locale: /vi|en/ do
    get "/register", to: "users#new"
    post "/register", to: "users#create"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    resources :posts, only: %i(show create new)
    root "posts#index"
  end
end
