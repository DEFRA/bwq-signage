# frozen-string-literal: true

# Service to manage the logo file for a particular named bathing water manager
class LogoManager
  attr_reader :params
  ENV_OPEN_DATA_BUCKET = 'environment-open-data'

  def initialize(params, client = nil)
    @params = params
    @client = client
  end

  def logo_name_root
    name = params[:'bwmgr-name']
    return nil unless name && !name.empty?

    @logo_name_root ||=
      name
      .downcase
      .strip
      .gsub(/\W/, '-')
      .gsub(/-+/, '-')
      .gsub(/(^-)|(-$)/, '')
  end

  def logo_object
    return nil unless logo_name_root
    @logo_object ||= find_logo
  end

  def find_logo
    find_logo_s3('png') ||
      find_logo_s3('jpg') ||
      find_logo_s3('gif')
  end

  def find_logo_s3(extn)
    s3_obj = env_open_data_bucket.object("bwq-signage-assets/#{logo_name_root}/logo.#{extn}")
    s3_obj.exists? && s3_obj
  end

  def env_open_data_bucket
    @bucket ||= s3.bucket(ENV_OPEN_DATA_BUCKET)
  end

  def s3
    client = @client || Aws::S3::Client.new(region: 'eu-west-1')
    @s3 ||= Aws::S3::Resource.new(client: client)
  end
end
