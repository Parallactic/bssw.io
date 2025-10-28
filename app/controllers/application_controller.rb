# frozen_string_literal: true

require 'zlib'
require 'rubygems/package'

# base class
class ApplicationController < ActionController::Base
  # With +respond_to do |format|+, "406 Not Acceptable" is sent on invalid format.
  # With a regular render (implicit or explicit), this exception is raised instead.
  # Log it to Exception Logger, but show users a 404 page instead of error 500.
  rescue_from(ActionView::MissingTemplate) do |e|
    not_found(e)
  end

  rescue_from StandardError, with: :send_error

  def page_item
    @resource || @page || @event || @post
  end

  def not_found(_exception = nil)
    request.format = :html
    render(
      template: 'errors/not_found_error',
      content_type: 'text/html',
      formats: [:html],
      layout: 'layouts/application',
      status: :not_found
    )
  end

  def send_error(exception)
    # respond_to do |format|
    #   format.any do
    if exception.is_a?(ActionController::RoutingError) ||
       exception.is_a?(ActiveRecord::RecordNotFound)
      not_found(exception)
    else
      render_error(exception)
    end
    #   end
    # end
  end

  def render_error(exception = nil)
    logger.error("500: rescued_from: #{print_exception(exception)}") if exception
    render(
      template: 'errors/internal_server_error',
      layout: 'layouts/application',
      status: :internal_server_error,
      formats: [:html]
    )
  end

  include ActionController::HttpAuthentication::Basic::ControllerMethods
  protect_from_forgery with: :exception
  before_action :set_announcement
  before_action :check_auth
  helper_method :scoped_resources
  helper_method :scoped_blog
  helper_method :page_item

  def robots
    robots = File.read(Rails.root + "config/robots/#{Rails.env}.txt")
    render plain: robots
  end

  private

  def print_exception(exception)
    "#{params[:controller]}##{params[:action]}:
    #{exception.inspect}\n#{exception.backtrace[0..50]}\n"
  end

  def check_auth
    session[:preview] = false
    return unless request.base_url.to_s.match?('preview')

    session[:preview] = true
    http_authenticate
  end

  def http_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.credentials[:preview][:name] &&
        password == Rails.application.credentials[:preview][:password]
    end
  end

  def scoped_resources
    SearchResult.published.displayed
  end

  def set_announcement
    @announcement = Announcement.displayed.for_today.first
  end

  def process_message(contact)
    flash.delete(:error)
    flash.delete(:notice)
    contact.request = request
    if contact.deliver
      flash[:notice] = 'Thank you for your message!'
    else
      flash[:error] =
        "Error: message not sent! #{contact.errors.full_messages.to_sentence}"
    end
  end
end
