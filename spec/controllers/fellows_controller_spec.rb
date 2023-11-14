# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FellowsController, type: :controller do
  render_views

  before do
    @rebuild = Rebuild.create
    RebuildStatus.all.each(&:destroy)
    RebuildStatus.create(display_rebuild_id: @rebuild.id)
  end

  describe 'get show' do
    it 'renders the show template' do
      fellow = FactoryBot.create(:fellow, rebuild_id: @rebuild.id, honorable_mention: nil)
      get :show, params: { id: fellow.slug }

      expect(response).to render_template 'show'
    end
  end

  describe 'get index' do
    it 'renders the index template' do
      FactoryBot.create(:fellow, rebuild_id: @rebuild.id)
      get :index
      expect(response).to render_template 'index'
    end
  end
end
