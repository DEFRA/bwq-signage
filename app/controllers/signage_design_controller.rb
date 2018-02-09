# frozen-string-literal: true

# Main controller for showing the report design user interface
class SignageDesignController < ApplicationController
  def show
    options = { params: validate_params }
    options[:search] = search if params[:search]
    options[:bathing_water] = load_bathing_water(params[:eubwid]) if params[:eubwid]
    options[:view_context] = view_context

    @view_state = BwqSign.new(options)
  end

  private

  def validate_params
    pp = permitted_params
    search.validate(pp, flash)
  end

  def permitted_params
    params.permit(*all_permitted_param_names)
  end

  def all_permitted_param_names
    %i[page_orientation step].concat(Workflow::ALL_PARAMS)
  end

  def search
    @search ||= BathingWaterSearch.new
  end

  def load_bathing_water(eubwid)
    BwqService.new.bathing_water_by_id(eubwid)
  end
end
