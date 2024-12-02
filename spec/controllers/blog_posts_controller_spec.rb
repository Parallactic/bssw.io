# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlogPostsController, type: :controller do
  render_views

  before do
    RebuildStatus.all.find_each(&:destroy)
    RebuildStatus.create(display_rebuild_id: Rebuild.create.id)
  end

  let(:rebuild) { RebuildStatus.displayed_rebuild }
  let(:credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials Rails.application.credentials[:preview][:name],
                                                                   Rails.application.credentials[:preview][:password]
  end

  describe 'preview' do
    it 'sets the preview val' do
      FactoryBot.create(:page, name: 'BSSw Blog', rebuild_id: rebuild.id)
      @request.env['HTTP_AUTHORIZATION'] = credentials
      @request.host = 'preview.bssw.io'
      get :index
      expect(session[:preview]).to be true
    end
  end

  describe 'index' do
    before do
      FactoryBot.create(:page, name: 'BSSw Blog', rebuild_id: rebuild.id)
      bp.authors = [author]
      bp_authored_by_author_a.authors = [a]
      bp3.tracks = [t]
    end

    let(:bp) { FactoryBot.create(:blog_post, rebuild_id: rebuild.id) }
    let(:author) { FactoryBot.create(:author, rebuild_id: rebuild.id) }
    let(:a) { FactoryBot.create(:author, rebuild_id: rebuild.id) }
    let(:t) { FactoryBot.create(:track, rebuild_id: rebuild.id) }
    let(:bp_authored_by_author_a) { FactoryBot.create(:blog_post, rebuild_id: rebuild.id) }
    let(:bp3) { FactoryBot.create(:blog_post, rebuild_id: rebuild.id) }

    it 'gets index with blog post' do
      get :index
      expect(assigns(:posts)).to include(bp)
    end

    it 'displays pages' do
      150.times { FactoryBot.create(:blog_post, rebuild_id: rebuild.id) }
      get :index, xhr: true
      expect(response).to render_template :index
    end

    it 'gets index with author' do
      get :index, params: { author: a.slug }
      expect(assigns(:posts)).to include bp_authored_by_author_a
    end

    it 'gets index with track' do
      get :index, params: { track: t.slug }
      expect(assigns(:posts)).to include bp3
    end

    it 'gets index with all' do
      get :index, params: { view: 'all' }
      expect(assigns(:posts)).to include bp
    end

    it 'does not include from wrong author' do
      get :index, params: { author: a.slug }
      expect(assigns(:posts)).not_to include bp
    end
  end

  describe 'show' do
    before do
      first_post = FactoryBot.create(:blog_post, rebuild_id: rebuild.id)
      next_post = FactoryBot.create(:blog_post, rebuild_id: rebuild.id)
      topic = FactoryBot.create(:topic, rebuild_id: rebuild.id)
      author = FactoryBot.create(:author, rebuild_id: rebuild.id)
      first_post.topics << topic
      next_post.topics << topic
      BlogPost.last.authors << author
    end

    it 'shows blog post' do
      get :show, params: { id: BlogPost.last }
      expect(assigns(:post)).to eq BlogPost.last
    end

    it 'shows related post' do
      get :show, params: { id: BlogPost.last }
      expect(assigns(:related_posts)).not_to be_empty
    end
  end
end
