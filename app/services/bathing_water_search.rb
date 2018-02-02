# frozen-string-literal: true

# A simple lookup service for finding bathing waters by name, EUBWID or bathing
# water controller name
class BathingWaterSearch
  # Search for a term that may be part of a bathing water name, a bathing water
  # ID or a bathing water controller
  def search(term)
    #
  end

  def validate(params, flash)
    return params unless (search_string = params[:search])

    if search_string.empty?
      message(flash, 'Problem with search term', nil, ['Empty search input'])
      params.delete(:search)
    elsif illegal_search_chars?(search_string)
      message(flash, 'Problem with search term', nil, ['Non-permitted characters in search input'])
      params.delete(:search)
    end

    params
  end

  private

  def illegal_search_chars?(search_string)
    !search_string.match?(/\A(\w|\s|-)+\Z/)
  end

  def api
    @api ||= BwqService.new
  end

  def message(flash, title, message, errors)
    flash[:title] = title if title
    flash[:message] = message if message
    flash[:errors] = errors if errors
  end
end
