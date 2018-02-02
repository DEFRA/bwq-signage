# frozen-string-literal: true

# Main controller for showing the report design user interface
class SignageDesignController < ApplicationController
  def show
    options = { params: validate_params }
    options[:bathing_water] = BathingWater.new(params[:eubwid]) if params[:eubwid]

    @view_state = BwqSign.new(options)
  end

  private

  def validate_params
    pp = permitted_params

    validate_search(pp)
    pp
  end

  def permitted_params
    params.permit(*Workflow::ALL_PARAMS)
  end

  def validate_search(pp)
    return unless (search_string = pp[:search])

    if search_string.empty?
      flash_message('Problem with search term', nil, ['Empty search input'])
      pp.delete(:search)
    elsif illegal_search_chars?(search_string)
      flash_message('Problem with search term', nil, ['Non-permitted characters in search input'])
      pp.delete(:search)
    end
  end

  def illegal_search_chars?(search_string)
    !search_string.match?(/\A(\w|\s|-)+\Z/)
  end

  def flash_message(title, message, errors)
    flash[:title] = title if title
    flash[:message] = message if message
    flash[:errors] = errors if errors
  end
end
