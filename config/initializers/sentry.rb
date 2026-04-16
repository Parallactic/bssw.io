# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = 'https://53a77a8822ea01c75a1bdce699f93b9b@o4511230104305664.ingest.us.sentry.io/4511230106009600'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Add data like request headers and IP for users,
  # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.send_default_pii = true
end

