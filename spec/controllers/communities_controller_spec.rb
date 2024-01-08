# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommunitiesController, type: :controller do
  render_views

  describe 'get show' do
    before do
      rebuild = Rebuild.create
      RebuildStatus.all.each(&:destroy)
      RebuildStatus.create(display_rebuild_id: rebuild.id)
    end

    it 'renders the show template' do
      FactoryBot.create(:page, name: 'Communities Overview', rebuild_id: rebuild.id)
      community = FactoryBot.create(:community, rebuild_id: rebuild.id)
      get :show, params: { id: community }
      expect(response).to render_template :show
    end
  end
end
