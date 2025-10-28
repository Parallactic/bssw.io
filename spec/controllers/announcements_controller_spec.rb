# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnouncementsController, type: :controller do
  describe 'close' do
    it 'gets close' do
      get :close, format: :js
      expect(response).to have_http_status(:no_content)
    end
  end
end
