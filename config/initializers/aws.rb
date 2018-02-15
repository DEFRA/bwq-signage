# frozen-string-literal: true

# In development and test, we use local AWS credentials to access the AWS services.
if Rails.env.development? || Rails.env.test?
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
