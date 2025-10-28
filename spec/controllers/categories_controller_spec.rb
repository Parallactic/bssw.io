# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  render_views

  describe 'get show' do
    it 'renders the show template' do
      category = FactoryBot.create(:category)
      get :show, params: { id: category }
      expect(response).to render_template 'show'
    end
  end
end
