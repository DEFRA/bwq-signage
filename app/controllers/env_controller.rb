# frozen-string-literal: true

# Controller serving state from the execution environment to JavaScript apps
class EnvController < ApplicationController
  layout false

  def show
    render json: {
      map_api: ENV['OS_API_KEY']
    }
  end
end
