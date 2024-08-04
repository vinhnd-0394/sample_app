Rails.application.routes.draw do
  scope "(:locale)", locale: /vi|en/ do
    resources :users, only: %i(new  create)
    root "static_page#index"
  end
end
