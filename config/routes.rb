Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :tools, only: :create
  post 'tools/update_translations', to: 'tools#update_translations'
  post 'tools/handle_webhook', to: 'tools#handle_webhook'
end
