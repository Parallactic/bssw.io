# frozen_string_literal: true

# render an error page if we get a bad request
class RefuseInvalidRequest
  def initialize(app)
    @app = app
  end

  def call(env)
    Rack::Utils.parse_nested_query(env['QUERY_STRING'].to_s)
    @app.call(env)
  rescue StandardError
    ApplicationController.action(:render_error).call(env)
  end
end
