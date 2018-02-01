# frozen_string_literal: true

Rails.application.routes.draw do
  root 'signage_design#show'
  get '/', to: 'signage_design#show'
  get 'preview', to: 'preview#show'
end
