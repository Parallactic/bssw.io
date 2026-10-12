# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  render_views
  
  controller do
    def missing_template
      render template: 'nonexistent/nothing'   # genuinely raises MissingTemplate
    end

    def boom
      raise StandardError, 'boom'
    end
  end

  describe "errors" do
  before do
    routes.draw do
      get 'missing_template' => 'anonymous#missing_template'
      get 'boom'             => 'anonymous#boom'
    end
  end

  it 'shows a 404 for a missing template' do
    get :missing_template

    expect(response).to have_http_status(:not_found)
  end

  it 'logs and renders a 500 for unexpected errors' do
    allow(controller.logger).to receive(:error)
    get :boom
    expect(response).to have_http_status(:internal_server_error)
    expect(controller.logger).to have_received(:error).with(/500: rescued_from.*boom/m)
  end
  end
end
