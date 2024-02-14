# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  render_views

  before do
    rebuild = Rebuild.create
    RebuildStatus.all.find_each(&:destroy)
    RebuildStatus.create(display_rebuild_id: rebuild.id)
    FactoryBot.create(:page,
                      name: 'Homepage',
                      path: 'Homepage.md',
                      slug: 'homepage',
                      rebuild_id: rebuild.id)
  end

  let(:rebuild) { RebuildStatus.displayed_rebuild }

  describe 'get about page' do
    it 'renders the show template' do
      FactoryBot.create(:page, rebuild_id: rebuild.id, name: 'Team')
      get :show, params: { id: 'about' }
      expect(response).to render_template :show
    end
  end

  describe 'get nonexistent page' do
    it 'renders the show template' do
      get :show, params: { id: 'nonexistent' }
      expect(response.status).to eq(404)
    end
  end

  it 'gets quote' do
    quote = FactoryBot.create(:quote, rebuild_id: rebuild.id)
    get :show, params: { id: 'homepage' }
    expect(assigns(:quote)).to eq quote
  end

  describe 'announcements' do
    let(:current_announcement) do
      FactoryBot.create(:announcement,
                        start_date: 1.day.ago,
                        end_date: 3.days.from_now,
                        rebuild_id: rebuild.id,
                        path: FactoryBot.create(:site_item).path)
    end
    let(:future_announcement) do
      FactoryBot.create(:announcement,
                        start_date: 1.day.from_now,
                        end_date: 3.days.from_now,
                        rebuild_id: rebuild.id)
    end
    let(:page) do
      Page.find_or_create_by(name: 'Homepage', rebuild_id: rebuild.id)
    end

    it 'gets announcement' do
      announcement = current_announcement
      get :show, params: { id: page.slug }
      expect(assigns(:announcement)).to eq announcement
    end

    it 'does not show announcement in future' do
      future_announcement
      get :show, params: { id: page.slug }
      expect(assigns(:announcement)).to be_nil
    end
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
