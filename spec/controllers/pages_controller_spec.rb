# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  render_views

  before do
    rebuild = Rebuild.create
    RebuildStatus.all.each(&:destroy)
    RebuildStatus.create(display_rebuild_id: rebuild.id)
  end

  let(:rebuild) { RebuildStatus.displayed_rebuild }

  describe 'get show' do
    it 'renders the show template' do
      FactoryBot.create(:page, rebuild_id: rebuild.id, name: 'Team')
      get :show, params: { id: 'about' }
      expect(response).to render_template :show
    end
  end

  describe 'get show' do
    it 'renders the show template' do
      get :show, params: { id: 'nonexistent' }
      expect(response.status).to eq(404)
    end
  end

  it 'gets quote' do
    page = FactoryBot.create(:page,
                             name: 'Homepage',
                             path: 'Homepage.md',
                             slug: 'homepage',
                             rebuild_id: rebuild.id)
    quote = FactoryBot.create(:quote, rebuild_id: rebuild.id)
    FactoryBot.create(:announcement,
                      start_date: 1.day.from_now,
                      end_date: 3.days.from_now,
                      rebuild_id: rebuild.id)
    get :show, params: { id: page.slug }
    expect(assigns(:quote)).to eq quote
    expect(assigns(:announcement)).to be_nil
  end

  it 'gets announcement' do
    page = FactoryBot.create(:page, name: 'Homepage', rebuild_id: rebuild.id)
    announcement = FactoryBot.create(:announcement,
                                     start_date: 1.day.ago,
                                     end_date: 3.days.from_now,
                                     rebuild_id: rebuild.id,
                                     path: FactoryBot.create(:site_item).path)
    get :show, params: { id: page.slug }
    expect(assigns(:quote)).to be_nil
    expect(assigns(:announcement)).to eq announcement
  end

  it 'gets contact' do
    FactoryBot.create(:page, name: 'Contact BSSw', rebuild_id: rebuild.id)
    get :show, params: { id: 'contact-bssw' }
    expect(response).to redirect_to(action: 'new', controller: 'contacts')
  end

  it 'lists fellows' do
    FactoryBot.create(:page, name: 'Meet Our Fellows', rebuild_id: rebuild.id)
    fellow = FactoryBot.create(:fellow, rebuild_id: rebuild.id)
    get :show, params: { id: 'meet-our-fellows' }
    expect(response.body).to match(fellow.name)
  end
end
