# frozen-string-literal: true

# Shared concerns for interacting with a remote LDA endpoint
module LdaApi
  FIRST_PAGE = 0
  ALL_PAGES = :all

  # Wrap the JSON API response with a facade pattern wrapper
  def api_get_resources(url, page, resource_type, o = {})
    json = api_get_json(url, page, o)
    json.is_a?(Hash) ? resource_type.new(json) : json.map { |r| resource_type.new(r) }
  end

  # Get the JSON value of the given URL
  # TODO this method needs refactoring! (the rubocop disables are a clue!)
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength,
  # rubocop:disable Metrics/PerceivedComplexity
  def api_get_json(url, page = ALL_PAGES, o = {})
    u = absolute_url(url)

    options = {}.merge(o)
    options[:_page] = page if page.is_a? Integer
    resp = []

    while u
      json = get_json(u, options)
      result = json['result']

      resp.concat(result['items']) unless item_endpoint?(page)
      resp = result['primaryTopic'] if item_endpoint?(page)

      u = (fetch_all?(page) || fetch_more?(o, resp)) && more?(result)
      options.delete(:_page) if u
    end

    resp
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength,
  # rubocop:enable Metrics/PerceivedComplexity

  private

  def item_endpoint?(page)
    page == :item
  end

  def fetch_all?(page)
    page == ALL_PAGES
  end

  # Return true if we should fetch more items for this page.
  # Post-condition: the responses array will contain at most
  # page items.
  def fetch_more?(options, resp)
    page_size = options[:_pageSize] || options['_pageSize']

    return unless page_size && resp.is_a?(Array)
    resp.pop while resp.length > page_size

    resp.length < page_size
  end

  def more?(result)
    result['next']
  end

  # Convert the given relative URL to absolute, using the current environment
  def absolute_url(url)
    url.match?(/^http:/) ? url : "#{url_root}#{url}"
  end

  # Convert the given URL to relative form by removing the hostname
  def relative_url(url)
    url.gsub(%r{\Ahttp://[^/]*}, '')
  end

  # Get parsed JSON from the given URL
  def get_json(url, options = {})
    r = connection(url).get do |req|
      req.headers['Accept'] = 'application/json'
      req.params.merge! options
    end

    raise "Failed to read from #{url}: #{r.status.inspect}" unless (200..207).cover?(r.status)
    JSON.parse(r.body)
  rescue StandardError => e
    raise(ApiRequestFailed, "API request to <#{url}> failed with: #{e.inspect}")
  end

  def connection(url)
    Faraday.new(url: url) do |faraday|
      faraday.request :url_encoded
      faraday.use FaradayMiddleware::FollowRedirects
      faraday.adapter :net_http
      faraday.response :logger, defined?(Rails) && Rails.logger
    end
  end
end
