# frozen_string_literal: true

Rails.application.routes.draw do
  root 'signage_design#show'
  get '/', to: 'signage_design#show'
  post '/', to: 'signage_design#upload'
  get '/final', to: 'bwq_sign_final#show'
  get '/download', to: 'bwq_sign_final#new'
end
