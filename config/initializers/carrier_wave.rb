# frozen-string-literal: true

CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
    provider: 'AWS',
    region: 'eu-west-1'
  }

  # Set the AWS profile, but only in dev. In prod, we pick up the IAM role automagically
  config.fog_credentials[:profile] = 'ea' if Rails.env.development?

  config.fog_directory = 'ea-open-data/bwq-signage-assets'
  config.fog_public = true
  config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }
end
