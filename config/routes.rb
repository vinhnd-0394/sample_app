Rails.application.routes.draw do
  scope "(:locale)", locale: /vi|en/ do
    get "/register", to: "users#new"
    post "/register", to: "users#create"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    resources :users, only: :show
    resources :posts, except: :index

    post "/follows/:id", to: "follows#create", as: "follow_user"
    delete "/unfollows/:id", to: "follows#destroy", as: "unfollow_user"
    post "/likes/:id", to: "likes#create", as: "like_post"
    delete "/unlikes/:id", to: "likes#destroy", as: "unlike_post"
    root "posts#index"
  end
end
