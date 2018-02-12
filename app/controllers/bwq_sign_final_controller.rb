# frozen-string-literal: true

# Controller for generating the final, non-preview view of the BWQ sign
class BwqSignFinalController < ApplicationController
  include SignageParameters
  layout 'bwq_sign_layout'

  def show
    options = { params: validate_params(%i[page_orientation]) }
    options[:search] = search if params[:search]
    options[:bathing_water] = load_bathing_water(params[:eubwid]) if params[:eubwid]
    options[:view_context] = view_context

    @view_state = BwqSign.new(options)
  end
end
