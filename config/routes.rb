require 'resque/server'

Rails.application.routes.draw do

  root to: 'products#search'
  get 'products/search'
  post 'products/search'

  post 'products/get'

  post 'products/record'
  post 'products/download'

  get 'products/setup'
  post 'products/setup'

  post 'products/regist'

  post 'products/delete'

  mount Resque::Server.new, at: "/resque"

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
    get '/sign_in' => 'devise/sessions#new'
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
