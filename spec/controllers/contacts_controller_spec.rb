# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactsController, type: :controller do
  render_views

  before do
    @rebuild = Rebuild.create
    RebuildStatus.all.find_each(&:destroy)
    RebuildStatus.create(display_rebuild_id: @rebuild.id)
    page = Page.create(name: 'Contact BSSw', rebuild_id: @rebuild.id, path: 'Contact.md')
    page.save
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
        post :create, params: { contact_form: { name: 'foo', email: 'foo@example.com' } }
      end.to change(ActionMailer::Base.deliveries, :count)
    end

    it 'does not send without name' do
      session[:invisible_captcha_timestamp] = Time.zone.now.iso8601
      sleep InvisibleCaptcha.timestamp_threshold

      expect do
        post :create, params: { contact_form: { name: nil, email: 'foo@example.com' } }
      end.not_to change(ActionMailer::Base.deliveries, :count)
    end

    it 'fails with bad info' do
      sleep InvisibleCaptcha.timestamp_threshold

      expect do
        post :create, params: { contact_form: { name: 'foo', email: 'foo' } }
      end.not_to change(ActionMailer::Base.deliveries, :count)
    end

    it 'wont send without recaptcha' do
      expect do
        post :create, params: { contact_form: { name: 'foo', email: 'foo@example.com' } }
      end.not_to change(ActionMailer::Base.deliveries, :count)
    end
  end
end
