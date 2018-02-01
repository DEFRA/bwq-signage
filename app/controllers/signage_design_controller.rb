# frozen-string-literal: true

# Main controller for showing the report design user interface
class SignageDesignController < ApplicationController
  def show
    options = { params: permitted_params }
    options[:bathing_water] = BathingWater.new(params[:eubwid]) if params[:eubwid]

    @view_state = BwqSign.new(options)
  end

  private

  def permitted_params
    params.permit(*Workflow::ALL_PARAMS)
  end
end
