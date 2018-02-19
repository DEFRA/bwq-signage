# frozen_string_literal: true

Rails.application.routes.draw do
  root 'signage_design#show'
  get '/', to: 'signage_design#show'
  post '/', to: 'signage_design#update'
  get '/final', to: 'bwq_sign_final#show'
  get '/download', to: 'bwq_sign_final#new'
  get '/env', to: 'env#show'
end
