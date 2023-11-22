# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResourcesController, type: :controller do
  render_views

  let(:rebuild) { Rebuild.first }
  let(:request) { @request }

  before do
    FactoryBot.create(:page, name: 'Resources')
    Rebuild.create
    RebuildStatus.all.each(&:destroy)
    RebuildStatus.create(display_rebuild_id: rebuild.id)
  end

  it 'shows not found page' do
    get :show, params: { id: 'foo' }
    expect(response.body).to match 'changing'
  end

  describe 'preview' do
    it 'is invalid without auth' do
      request.host = 'preview.bssw.io'
      credentials = ActionController::HttpAuthentication::Basic.encode_credentials 'name', 'pw'
      request.env['HTTP_AUTHORIZATION'] = credentials
      get 'index'
      expect(response).not_to render_template 'index'
    end

    it 'is valid with auth' do
      request.host = 'preview.bssw.io'
      name = Rails.application.credentials[:preview][:name]
      pw = Rails.application.credentials[:preview][:password]
      credentials = ActionController::HttpAuthentication::Basic.encode_credentials name, pw
      request.env['HTTP_AUTHORIZATION'] = credentials
      get 'index'
      expect(response).to render_template 'index'
    end

    it 'sets the preview val' do
      @request.host = 'preview.bssw.io'
      name = Rails.application.credentials[:preview][:name]
      pw = Rails.application.credentials[:preview][:password]
      credentials = ActionController::HttpAuthentication::Basic.encode_credentials name, pw
      request.env['HTTP_AUTHORIZATION'] = credentials
      get 'index'
      expect(session[:preview]).to be true
    end
  end

  describe 'get search' do
    it 'searches' do
      name = Rails.application.credentials[:preview][:name]
      pw = Rails.application.credentials[:preview][:password]
      credentials = ActionController::HttpAuthentication::Basic.encode_credentials name, pw
      request.env['HTTP_AUTHORIZATION'] = credentials

      resource = FactoryBot.create(:resource, publish: true, type: 'Resource')
      expect(SiteItem.published.displayed).to include(resource)

      SearchResult.reindex!
      sleep(5)
      get :search, params: { search_string: resource.name }
      expect(assigns(:resources)).to include(resource)
    end

    it 'finds fellows' do
      request.env['HTTP_AUTHORIZATION'] = "Basic {Base64.encode64('preview-bssw:SoMyCodeWillSeeTheFuture!!')}"
      resource = FactoryBot.create(:resource, publish: true, type: 'Resource', name: 'Blorgon')

      fellow = FactoryBot.create(:fellow, name: 'Joe Blow', rebuild_id: RebuildStatus.displayed_rebuild.id,
                                          publish: true)
      SearchResult.reindex
      sleep(5)

      get :search, params: { search_string: 'Joe' }

      expect(assigns(:resources)).to include(fellow)
      expect(assigns(:resources)).not_to include(resource)
    end

    describe 'finds pages' do
      before do
        request.env['HTTP_AUTHORIZATION'] = "Basic {Base64.encode64('preview-bssw:SoMyCodeWillSeeTheFuture!!')}"
        resource = FactoryBot.create(:resource, publish: true, type: 'Resource', name: 'Blorgon')
        page = FactoryBot.create(:page, name: 'Joe', content: 'Blow',
                                        rebuild_id: RebuildStatus.displayed_rebuild.id, publish: true)
        SearchResult.reindex
        sleep(5)
      end

      it 'shows the page' do
        get :search, params: { search_string: 'Joe' }
        expect(assigns(:resources)).to include(Page.last)
      end
    end

    it 'renders template' do
      get :search
      expect(response).to render_template :index
    end

    it 'shows recent' do
      get :index, params: { recent: true }
      expect(response).to render_template :index
    end

    it 'performs an empty search' do
      get :search, params: { search_string: 'foob' }
      SearchResult.reindex!
      sleep(5)

      expect(assigns(:resources)).to be_empty
    end

    it 'performs a simple search' do
      resource = FactoryBot.create(:resource, name: 'foob')
      SearchResult.reindex!
      sleep(5)

      get :search, params: { search_string: 'foob' }
      expect(assigns(:resources)).to include(resource)
    end

    it 'performs a simple search' do
      resource = FactoryBot.create(:resource, name: 'foob')
      SearchResult.reindex!
      sleep(5)

      get :search, params: { search_string: "'foob'" }
      expect(assigns(:resources)).to include(resource)
    end

    it 'finds fellows' do
      fellow = FactoryBot.create(:fellow, name: 'bar bar', rebuild_id: RebuildStatus.displayed_rebuild.id,
                                          publish: true)
      SearchResult.reindex!
      sleep(15)
      get :search, params: { search_string: 'bar' }
      expect(assigns(:resources)).to include(fellow)
    end

    it 'performs a more complex search' do
      resource = FactoryBot.create(:resource, content: 'Four score and seven')
      SearchResult.reindex!
      sleep(5)
      get :search, params: { search_string: 'four seven' }
      expect(assigns(:resources)).to include(resource)
    end

    it 'respects quote marks in search' do
      resource = FactoryBot.create(:resource, content: 'Four score and seven')
      SearchResult.reindex
      sleep(5)
      get :search, params: { search_string: '"four seven"' }

      expect(assigns(:resources)).not_to include(resource)
    end

    it 'finds quoted terms in search' do
      resource = FactoryBot.create(:resource, content: 'Four score and seven')
      SearchResult.reindex
      sleep(5)
      get :search, params: { search_string: '"four score"' }
      expect(assigns(:resources)).to include(resource)
    end

    it 'finds searches and renders' do
      resource = FactoryBot.create(:resource, content: 'search string')

      resource2 = FactoryBot.create(:resource, content: 'bloo bloo')
      #      expect(resource.content).not_to be_blank
      expect(Resource.displayed).to include(resource2)
      expect(Resource.displayed).to include(resource)
      #      SiteItem.all.each(&:set_search_text)
      SearchResult.reindex!
      sleep(8)
      expect(SearchResult.algolia_search(resource.name)).to include(resource)
      get :search, params: { search_string: resource.name }
      expect(assigns(:search)).to eq(resource.name)
      expect(assigns(:resources)).to include(resource)
      expect(assigns(:resources)).not_to eq Resource.all

      expect(assigns(:resources)).not_to include(resource2)
      expect(response.body).to match "mark>#{resource.name}"
    end
  end

  describe 'get authors' do
    it 'renders template' do
      author = FactoryBot.create(:author, rebuild_id: rebuild.id)
      resource = FactoryBot.create(:resource, rebuild_id: rebuild.id)
      resource.contributions << Contribution.create(author:, display_name: author.display_name)
      RebuildStatus.all.each(&:destroy)
      RebuildStatus.create(display_rebuild_id: rebuild.id)
      FactoryBot.create(:page, name: 'Contributors', path: 'Contributors.md', rebuild_id: rebuild.id)
      get :authors
      expect(response.body).to match(author.display_name)
    end
  end

  describe 'get show' do
    it 'renders the show template' do
      resource = FactoryBot.create(:resource, rebuild_id: rebuild.id)

      resource.categories << FactoryBot.create(:category)
      get :show, params: { id: resource }
      expect(response).to render_template :show
    end

    it 'renders the show template or what_is / how_to' do
      what_is = FactoryBot.create(:what_is, publish: true, rebuild_id: rebuild.id)
      get :show, params: { id: what_is }
      expect(response).to render_template 'resources/show'
    end
  end

  describe 'get index' do
    it 'renders the index template' do
      preview = FactoryBot.create(:resource, publish: false, preview: true)
      get :index, params: { view: 'all' }
      expect(response).to render_template :index
      expect(assigns(:resources)).not_to include(preview)
    end

    it 'displays pages' do
      FactoryBot.create_list(:resource, 150)
      get :search, params: { page: 1 }, xhr: true
      expect(response).to render_template :index
    end

    it 'can use topics' do
      topic = FactoryBot.create(:topic, rebuild_id: rebuild.id)
      topiced_resource = FactoryBot.create(:resource, rebuild_id: rebuild.id)
      untopiced_resource = FactoryBot.create(:resource, rebuild_id: rebuild.id)
      topiced_resource.topics << topic
      get :index, params: { topic: topic.slug }
      expect(assigns(:resources)).to include(topiced_resource)
      expect(assigns(:resources)).not_to include(untopiced_resource)
      expect(assigns(:resources).size).to be < 2
    end

    it 'can use categories' do
      category = FactoryBot.create(:category, rebuild_id: rebuild.id)
      topic = FactoryBot.create(:topic, category:, rebuild_id: rebuild.id)
      resource_with_category = FactoryBot.create(:resource, rebuild_id: rebuild.id)
      resource_without_category = FactoryBot.create(:resource, rebuild_id: rebuild.id)
      resource_with_category.topics << topic
      get :index, params: { category: category.slug }
      expect(assigns(:resources)).to include(resource_with_category)
      expect(assigns(:resources)).not_to include(resource_without_category)
    end

    describe 'using authors' do
      let(:author) { FactoryBot.create(:author, rebuild_id: rebuild.id) }
      let(:resource_with_author) { FactoryBot.create(:resource, rebuild_id: rebuild.id) }

      before do
        resource_with_author.authors << author
      end

      it 'includes the right resource' do
        get :index, params: { author: author.slug }
        expect(assigns(:resources)).to include resource_with_author
      end

      it 'does not include the wrong one' do
        resource_without_author = FactoryBot.create(:resource, rebuild_id: rebuild.id)
        get :index, params: { author: author.slug }
        expect(assigns(:resources)).not_to include resource_without_author
      end
    end

    it 'is in alpha order' do
      old_resource = FactoryBot.create(:resource, published_at: 1.week.ago, name: 'AA', rebuild_id: rebuild.id)
      FactoryBot.create(:resource, published_at: 2.weeks.ago, rebuild_id: rebuild.id)
      FactoryBot.create(:resource, published_at: Time.zone.today, name: 'BB', rebuild_id: rebuild.id)
      get :index
      expect(assigns(:resources).first).to eq old_resource
    end
  end

  describe 'rss feed' do
    it 'shows nothing' do
      FactoryBot.create_list(:resource, 5)
      get :index, format: :rss
      expect(response.media_type).to eq 'application/rss+xml'
    end

    it 'shows feed' do
      5.times { FactoryBot.create(:resource, rss_date: 1.week.ago, rebuild_id: rebuild.id) }
      get :index, format: :rss
      expect(assigns(:resources)).not_to be_empty
    end
  end
end
