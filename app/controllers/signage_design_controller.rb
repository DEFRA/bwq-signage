# frozen-string-literal: true

# Main controller for showing the report design user interface
class SignageDesignController < ApplicationController
  include SignageParameters

  IMAGE_FILE_TYPES = {
    'image/png' => 'png',
    'image/jpeg' => 'jpg',
    'image/gif' => 'gif'
  }.freeze

  def show
    options = { params: validate_params(%i[page_orientation step]) }
    options[:search] = search if params[:search]
    options[:bathing_water] = load_bathing_water(params[:eubwid]) if params[:eubwid]
    options[:view_context] = view_context

    @view_state = BwqSign.new(options)
  end

  def upload
    if (upload_file = validate_upload_params)
      upload_image_to_s3(upload_file)
    end

    show
    render template: 'signage_design/show'
  end

  def validate_upload_params
    upload_file = params[:'logo-file']

    validate_has_upload?(upload_file) &&
      validate_acceptable_file_type?(upload_file) &&
      validate_has_bwmgr_name? &&
      upload_file
  end

  def validate_has_upload?(upload_file)
    unless upload_file
      flash[:title] = 'Something went wrong'
      flash[:message] = 'No image file was uploaded.'
      return nil
    end

    true
  end

  def validate_acceptable_file_type?(upload_file)
    unless acceptable_file_type?(upload_file)
      flash[:title] = 'Something went wrong'
      flash[:message] =
        "Uploaded file type #{upload_file.content_type} was not recognised as an image."
      return nil
    end

    true
  end

  def validate_has_bwmgr_name?
    if !params[:'bwmgr-name'] || params[:'bwmgr-name'].empty?
      flash[:title] = 'Something went wrong'
      flash[:message] = 'Bathing water manager name must not be empty'
      return nil
    end

    true
  end

  def acceptable_file_type?(upload_file)
    IMAGE_FILE_TYPES.key?(upload_file.content_type)
  end

  def upload_image_to_s3(upload_file)
    lm = LogoManager.new(params)
    object = lm.upload_and_replace(upload_file, IMAGE_FILE_TYPES[upload_file.content_type])

    params[:'bwmgr-logo'] = object.key if object
    params.delete(:'logo-file')
  end
end
