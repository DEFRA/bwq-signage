# frozen-string-literal: true

# Main controller for showing the report design user interface
class SignageDesignController < ApplicationController
  def show
    options = { params: validate_params }
    options[:bathing_water] = BathingWater.new(params[:eubwid]) if params[:eubwid]
    options[:search] = search if params[:search]

    @view_state = BwqSign.new(options)
  end

  private

  def validate_params
    pp = permitted_params
    search.validate(pp, flash)
  end

  def permitted_params
    params.permit(*Workflow::ALL_PARAMS)
  end

  def search
    @search ||= BathingWaterSearch.new
  end
end
