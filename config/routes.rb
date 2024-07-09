Rails.application.routes.draw do
  scope "(:locale)", locale: /vi|en/ do
    root "static_page#index"
  end
end
