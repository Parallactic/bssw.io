# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlogPostsController, type: :controller do
  render_views

  before do
    rebuild = Rebuild.create
    RebuildStatus.all.each(&:destroy)
    RebuildStatus.create(display_rebuild_id: rebuild.id)
  end

  describe 'preview' do
    it 'sets the preview val' do
      FactoryBot.create(:page, name: 'BSSw Blog', rebuild_id: rebuild.id)
      @request.env['HTTP_AUTHORIZATION'] = "Basic #{Base64.encode64('preview-bssw:SoMyCodeWillSeeTheFuture!!')}"
      @request.host = 'preview.bssw.io'
      get :index
      expect(session[:preview]).to be true
    end
  end

  describe 'index' do
    it 'gets index' do
      FactoryBot.create(:page, name: 'BSSw Blog', rebuild_id: rebuild.id)
      bp = FactoryBot.create(:blog_post, rebuild_id: rebuild.id)
      expect(bp).to be_valid
      author = FactoryBot.create(:author, rebuild_id: rebuild.id)
      bp.authors << author
      expect(BlogPost.published).to include(bp)
      get :index
      expect(assigns(:posts)).to include(bp)
      expect(assigns(:posts)).not_to be_empty
    end

    it 'displays pages' do
      150.times { FactoryBot.create(:blog_post, rebuild_id: rebuild.id) }
      get :index, xhr: true
      expect(response).to render_template :index
    end

    it 'gets index with author' do
      FactoryBot.create(:page, name: 'BSSw Blog')
      a = FactoryBot.create(:author, rebuild_id: rebuild.id)
      bp = FactoryBot.create(:blog_post, rebuild_id: rebuild.id)
      bp2 = FactoryBot.create(:blog_post, rebuild_id: rebuild.id)
      bp2.authors = [a]
      get :index, params: { author: a.slug }
      expect(assigns(:posts)).to include bp2
      expect(assigns(:posts)).not_to include bp
    end
  end

  describe 'show' do
    it 'shows' do
      first_post = FactoryBot.create(:blog_post, rebuild_id: rebuild.id)
      next_post = FactoryBot.create(:blog_post, rebuild_id: rebuild.id)
      topic = FactoryBot.create(:topic, rebuild_id: rebuild.id)
      author = FactoryBot.create(:author, rebuild_id: rebuild.id)
      first_post.topics << topic
      next_post.topics << topic
      BlogPost.last.authors << author
      get :show, params: { id: BlogPost.last }
      expect(assigns(:post)).to eq BlogPost.last
      expect(assigns(:related_posts)).not_to be_empty
    end
  end
end
