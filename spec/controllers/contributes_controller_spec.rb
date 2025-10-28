# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContributesController, type: :controller do
  before do
    InvisibleCaptcha.init!
    InvisibleCaptcha.timestamp_threshold = 1
    InvisibleCaptcha.spinner_enabled = false
  end

  describe 'get new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template 'new'
    end
  end

  describe 'post create' do
    it 'sends mail' do
      session[:invisible_captcha_timestamp] = Time.zone.now.iso8601
      sleep InvisibleCaptcha.timestamp_threshold

      expect do
        post :create, params: { contribute: { name: 'foo', email: 'foo@example.com' } }
      end.to change(ActionMailer::Base.deliveries, :count)
    end
  end
end
