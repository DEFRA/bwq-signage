# frozen-string-literal: true

# Presenter for view state for bathing water signs
class BwqSign
  # No. of description chars before we drop the font-size to make it fit
  LONG_DESCRIPTION_LIMIT = 400

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

  def final?
    options[:final]
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

  def logo_manager
    @logo_manager ||= LogoManager.new(params)
  end

  def show_bwmgr_logo?
    params[:'bwmgr-logo'] &&
      params[:'bwmgr-logo'] != 'none'
  end

  def bwmgr_logo_url
    key = params[:'bwmgr-logo']
    key && "https://environment-open-data.s3.eu-west-1.amazonaws.com/#{key}"
  end

  def next_by_bw_controller
    id_current = bathing_water.eubwid
    controller_bws = BwqService.new.bws_in_same_controller(bathing_water)
    i = controller_bws.find_index { |bw| bw.eubwid == id_current }
    controller_bws[(i + 1) % controller_bws.length]
  end

  def classifications(bw = nil)
    @classifications ||= Classifications.new(bw || bathing_water, view_context, final?)
  end

  def pollution_sources_css_class
    base = show_prf? ? 'o-content-unit__1-2' : 'o-content-unit__1-1c'
    bathing_water.long_pollution_description?(LONG_DESCRIPTION_LIMIT) ? "#{base} u-long-text" : base
  end
end
