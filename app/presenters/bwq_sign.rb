# frozen-string-literal: true

CLASSIFICATION_IMAGE_ROOTS = {
  'http://environment.data.gov.uk/def/bwq-cc-2015/1' =>
      { src: 'baignade-3-stars', alt: 'excellent water quality' },
  'http://environment.data.gov.uk/def/bwq-cc-2015/2' =>
      { src: 'baignade-2-stars', alt: 'good water quality' },
  'http://environment.data.gov.uk/def/bwq-cc-2015/3' =>
      { src: 'baignade-1-star', alt: 'sufficient water quality' },
  'http://environment.data.gov.uk/def/bwq-cc-2015/4' =>
      { src: 'baignade-no-stars-no-bathing', alt: 'poor water quality' }
}.freeze

# Presenter for view state for bathing water signs
class BwqSign
  attr_reader :options

  def initialize(options)
    @options = options
  end

  def bathing_water
    options[:bathing_water]
  end

  def params
    options[:params]
  end

  def next_workflow_step
    Workflow.next_step(params)
  end

  def search_term
    params[:search]
  end

  def search_results
    @search_results ||= options[:search].search(search_term)
  end

  def show_preview?
    next_workflow_step == :preview
  end

  def landscape?
    params[:page_orientation] != 'portrait'
  end

  def page_orientation
    {
      current: landscape? ? 'landscape' : 'portrait',
      current_icon: landscape? ? 'fa-picture-o' : 'fa-file-picture-o',
      alt: landscape? ? 'portrait' : 'landscape',
      alt_icon: landscape? ? 'fa-file-picture-o' : 'fa-picture-o'
    }
  end

  def with_query_params(options)
    params.to_h.merge(options)
  end

  def monitoring_statement
    start_date, end_date = bathing_water.season_dates.map { |date| date.strftime('%B') }
    "Water quality is monitored from #{start_date}&nbsp;to&nbsp;#{end_date}".html_safe
  end

  # The Rails view context is passed in from the controller
  def view_context
    options[:view_context]
  end

  def classification_image_full(uri = nil)
    classification_uri = uri || bathing_water.latest_classification.uri
    image_root = CLASSIFICATION_IMAGE_ROOTS[classification_uri]

    {
      alt: image_root[:alt],
      src: "https://environment.data.gov.uk/bwq/profiles/images/#{image_root[:src]}.png",
      srcset: "https://environment.data.gov.uk/bwq/profiles/images/#{image_root[:src]}.svg"
    }
  end

  def classification_image_compact(uri = nil)
    classification_uri = uri || bathing_water.latest_classification.uri
    image_root = CLASSIFICATION_IMAGE_ROOTS[classification_uri]
    svg_image = "#{image_root[:src].gsub(/baignade-/, '')}.svg"

    {
      alt: image_root[:alt],
      src: view_context.image_path(svg_image)
    }
  end

  # Only show PRF summary if the BW is in PRF programmne
  def show_prf?
    bathing_water['latestProfile.pollutionRiskForecasting'].val == 'true'
  end

  def qr_code_url
    "http://environment.data.gov.uk/bwq/profiles/images/qr/#{bathing_water.eubwid}-100x100.png"
  end

  def show_map?
    params[:'show-map'] == 'yes'
  end

  def show_history?
    params[:'show-hist'] == 'yes'
  end

  def show_logo?
    params[:'show-logo'] == 'yes'
  end

  def bw_manager
    {
      name: params[:'bwmgr-name'],
      email: params[:'bwmgr-email'],
      phone: params[:'bwmgr-phone']
    }
  end

  def hidden_params(omit)
    params
      .to_h
      .to_a
      .reject { |key, _value| omit.include?(key.to_sym) }
  end
end
