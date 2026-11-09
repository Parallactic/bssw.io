# frozen_string_literal: true

# Octokit's default middleware stack, but with a persistent HTTP adapter so
# repeated GitHub API calls (one per author/file during a rebuild) reuse the
# TLS connection instead of opening a new one each time.
Octokit.middleware = Faraday::RackBuilder.new do |builder|
  retry_exceptions = Faraday::Request::Retry::DEFAULT_EXCEPTIONS + [Octokit::ServerError]
  builder.use Faraday::Request::Retry, exceptions: retry_exceptions
  builder.use Octokit::Middleware::FollowRedirects
  builder.use Octokit::Response::RaiseError
  builder.use Octokit::Response::FeedParser
  builder.adapter :net_http_persistent
end
