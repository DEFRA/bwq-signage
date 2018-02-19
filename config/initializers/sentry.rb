# frozen-string-literal: true

# Sentry monitors exceptions at run-time
if Rails.env.production?
  Raven.configure do |config|
    config.dsn = 'https://a893b64b570a4af38a6d410c935a0bea:f4562fe9d8d945519112744da428f139@sentry.io/281446'
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  end
end
