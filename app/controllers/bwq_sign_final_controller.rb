# frozen-string-literal: true

# Controller for generating the final, non-preview view of the BWQ sign
class BwqSignFinalController < ApplicationController
  include SignageParameters
  layout 'bwq_sign_layout'

  HOST = 'localhost'

  def show
    options = { params: validate_params(%i[page_orientation]) }
    options[:search] = search if params[:search]
    options[:bathing_water] = load_bathing_water(params[:eubwid]) if params[:eubwid]
    options[:view_context] = view_context

    @view_state = BwqSign.new(options)
  end

  def new
    file = Tempfile.new('page-final')
    command = "#{nodejs} ./bin/save-pdf.js '#{page_url}' #{orientation} #{page_size} '#{file.path}'"
    Rails.logger.debug("command: #{command.inspect}")
    result = system(command)

    render text: result.to_s
  end

  # TODO: this may change, as we decide the right URL for the Chrome to-pdf
  # process to visit
  def bwq_sign_final_url(params)
    port = Rails.env.development? ? 3000 : 80
    relative = Rails.application.config.relative_url_root || '/'
    final_url({ host: HOST, port: port, script_name: relative }.merge(params))
  end

  def orientation
    params[:page_orientation] || 'landscape'
  end

  def page_size
    params[:page_size] || 'a4'
  end

  def page_url
    bwq_sign_final_url(validate_params(%i[page_orientation]))
  end

  def nodejs
    Rails.application.config.node_executable
  end
end
