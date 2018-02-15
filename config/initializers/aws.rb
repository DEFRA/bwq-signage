# frozen-string-literal: true

# In development and test, we use local AWS credentials to access the AWS services.
if ENV['TRAVIS']
  # give fake keys because we rely on VCR not to cause any network requests
  Aws.config.update(
    access_key_id: '00000000000000000000',
    secret_access_key: '0000000000000000000000000000000000000000'
  )
elsif Rails.env.development? || Rails.env.test?
  shared_creds = Aws::SharedCredentials.new(profile_name: 'ea')
  Aws.config.update(
    region: 'eu-west-1',
    credentials: shared_creds.credentials
  )
else
  Aws.config.update(
    region: 'eu-west-1'
  )
end
