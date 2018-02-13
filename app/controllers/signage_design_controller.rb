# frozen-string-literal: true

# Main controller for showing the report design user interface
class SignageDesignController < ApplicationController
  include SignageParameters

  def show
    options = { params: validate_params(%i[page_orientation step]) }
    options[:search] = search if params[:search]
    options[:bathing_water] = load_bathing_water(params[:eubwid]) if params[:eubwid]
    options[:view_context] = view_context

    @view_state = BwqSign.new(options)
  end
end
