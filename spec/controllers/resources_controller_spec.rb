# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResourcesController, type: :controller do
  render_views

  let(:rebuild) { Rebuild.first }
  let(:request) { @request }
  let(:bad_credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials 'name', 'pw'
  end
  let(:good_credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials Rails.application.credentials[:preview][:name],
                                                                   Rails.application.credentials[:preview][:password]
  end

  before do
    FactoryBot.create(:page, name: 'Resources')
    Rebuild.create
    RebuildStatus.all.find_each(&:destroy)
    RebuildStatus.create(display_rebuild_id: rebuild.id)
  end

  it 'shows not found page' do
    get :show, params: { id: 'foo' }
    expect(response.body).to match 'changing'
  end

  describe 'menus' do

    it 'shows resource path' do
      resource = FactoryBot.create(:resource, type: 'Resource')
      get :index
      get :show, params: { id: resource.id }

expect(Nokogiri::HTML(response.body).css('.breadcrumbs').text).to     match 'Resources'
    end
    it 'shows topic path' do
      resource = FactoryBot.create(:resource)
      topic = FactoryBot.create(:topic)
      resource.topics << topic
      get :index, params: { topic: topic.slug }
      get :show, params: { id: resource.id }
      expect(Nokogiri::HTML(response.body).css('.breadcrumbs').text).to     match topic.name
    end
    it 'shows category path' do
      resource = FactoryBot.create(:resource)
      topic = FactoryBot.create(:topic)
      resource.topics << topic
      get :index, params: { category: topic.category.slug }
      get :show, params: { id: resource.id }
      expect(Nokogiri::HTML(response.body).css('.breadcrumbs').text).to     match topic.category.name

    end
  end
  
describe 'preview' do
    it 'is invalid without auth' do
      request.host = 'preview.bssw.io'
      request.env['HTTP_AUTHORIZATION'] = bad_credentials
      get 'index'
      expect(response).not_to render_template 'index'
    end

    it 'is valid with auth' do
      request.host = 'preview.bssw.io'
      request.env['HTTP_AUTHORIZATION'] = good_credentials
      get 'index'
      expect(response).to render_template 'index'
    end

    it 'sets the preview val' do
      request.host = 'preview.bssw.io'
      request.env['HTTP_AUTHORIZATION'] = good_credentials
      get 'index'
      expect(session[:preview]).to be true
    end
  end

  describe 'alias' do
    it 'redirects' do
      resource = FactoryBot.create(:resource, publish: true, type: 'Resource', alias: 'mystring')
      get :alias, params: { alias: resource.alias }
      expect(response.body).to redirect_to("/items/#{resource.slug}")
    end
  end

  describe 'get search' do
    before do
      name = Rails.application.credentials[:preview][:name]
      pw = Rails.application.credentials[:preview][:password]
      credentials = ActionController::HttpAuthentication::Basic.encode_credentials name, pw
      request.env['HTTP_AUTHORIZATION'] = credentials
    end

    it 'searches' do
      resource = FactoryBot.create(:resource, publish: true, type: 'Resource',
                                              rebuild_id: RebuildStatus.displayed_rebuild.id)
      FactoryBot.create(:resource, publish: true, type: 'Resource', rebuild_id: RebuildStatus.displayed_rebuild.id)
      author = FactoryBot.create(:author, publish: true, first_name: "#{resource.name} auth",
                                          rebuild_id: RebuildStatus.displayed_rebuild.id)
      FactoryBot.create(:page, publish: true, name: "#{resource.name} page",
                               rebuild_id: RebuildStatus.displayed_rebuild.id)
      SearchResult.reindex!
      sleep(5)
      get :search, params: { search_string: resource.name }
      expect(assigns(:resources)).to include(author)
    end

    describe 'finds fellows' do
      let(:resource) { FactoryBot.create(:resource, publish: true, type: 'Resource', name: 'Blorgon') }

      let(:fellow) do
        FactoryBot.create(:fellow, name: 'Joe Blow', rebuild_id: RebuildStatus.displayed_rebuild.id,
                                   publish: true)
      end

      before do
        request.env['HTTP_AUTHORIZATION'] = "Basic {Base64.encode64('preview-bssw:SoMyCodeWillSeeTheFuture!!')}"

        fellow
        resource
      end

      it 'has fellow' do
        SearchResult.reindex!
        sleep(5)

        get :search, params: { search_string: 'Joe' }

        expect(assigns(:resources)).to include(fellow)
      end

      it 'does not have resource' do
        SearchResult.reindex!
        sleep(5)

        get :search, params: { search_string: 'Joe' }

        expect(assigns(:resources)).not_to include(resource)
      end
    end

    describe 'finds pages' do
      before do
        FactoryBot.create(:page, name: 'Joe', content: 'Blow',
                                 rebuild_id: RebuildStatus.displayed_rebuild.id, publish: true)
        FactoryBot.create(:resource, publish: true, type: 'Resource', name: 'Blorgon')
        request.env['HTTP_AUTHORIZATION'] = "Basic {Base64.encode64('preview-bssw:SoMyCodeWillSeeTheFuture!!')}"
        SearchResult.reindex
        sleep(5)
      end

      it 'shows the page' do
        get :search, params: { search_string: 'Joe' }
        expect(assigns(:resources)).to include(Page.displayed.where(name: 'Joe').first)
      end
    end

    it 'renders template' do
      get :search
      expect(response).to render_template :index
    end

    it 'performs an empty search' do
      get :search, params: { search_string: 'foob' }
      SearchResult.reindex
      sleep(5)

      expect(assigns(:resources)).to be_empty
    end

    describe 'simple search' do
      let(:resource) { FactoryBot.create(:resource, name: 'foob') }
      let(:other_resource) { FactoryBot.create(:resource, name: 'boof') }

      before do
        resource
        other_resource
        SearchResult.reindex
        sleep(10)
      end

      it 'finds the resource' do
        get :search, params: { search_string: 'foob' }
        expect(assigns(:resources)).to include(resource)
      end

      it 'does not find the other resource' do
        get :search, params: { search_string: "'foob'" }
        expect(assigns(:resources)).not_to include(other_resource)
      end
    end

    # it 'finds fellows' do
    #   fellow = FactoryBot.create(:fellow, name: 'bar bar', rebuild_id: RebuildStatus.displayed_rebuild.id,
    #                                       publish: true)
    #   SearchResult.reindex!
    #   sleep(15)
    #   get :search, params: { search_string: 'bar' }
    #   expect(assigns(:resources)).to include(fellow)
    # end

    it 'performs a more complex search' do
      seven_resource = FactoryBot.create(:resource, content: 'Four score and seven')
      SearchResult.reindex
      sleep(15)
      get :search, params: { search_string: 'four seven' }
      expect(assigns(:resources)).to include(seven_resource)
    end

    it 'respects quote marks in search' do
      seven_resource = FactoryBot.create(:resource, content: 'Four score and seven')
      SearchResult.reindex!
      sleep(5)
      get :search, params: { search_string: '"four seven"' }
      puts assigns(:search_string)
      puts assigns(:resources)

      expect(assigns(:resources)).not_to include(seven_resource)
    end

    it 'finds quoted terms in search' do
      resource = FactoryBot.create(:resource, content: 'Four score and seven')
      SearchResult.reindex!
      sleep(5)
      get :search, params: { search_string: '"four score"' }
      expect(assigns(:resources)).to include(resource)
    end

    describe 'searching and rendering' do
      let(:resource) { FactoryBot.create(:resource, content: 'search string') }
      let(:resource2) { FactoryBot.create(:resource, content: 'bloo bloo') }

      before do
        resource
        resource2
        SearchResult.reindex!
        sleep(8)
      end

      it 'keeps search string' do
        get :search, params: { search_string: resource.name }
        expect(assigns(:search)).to eq(resource.name)
      end

      it 'assigns resource' do
        get :search, params: { search_string: resource.name }
        expect(assigns(:resources)).to include(resource)
      end

      it "doesn't show everything" do
        get :search, params: { search_string: resource.name }
        expect(assigns(:resources)).not_to include(resource2)
      end

      it 'renders marks' do
        puts resource.name
        get :search, params: { search_string: resource.name.to_s }
        expect(response.body).to match "mark>#{resource.name}"
      end
    end
  end

  describe 'get authors' do
    before do
      author = FactoryBot.create(:author, rebuild_id: rebuild.id)
      resource = FactoryBot.create(:resource, rebuild_id: rebuild.id)
      resource.contributions << Contribution.create(author:, display_name: author.display_name)
      # RebuildStatus.all.each(&:destroy)
      # RebuildStatus.create(display_rebuild_id: rebuild.id)
    end

    it 'renders template' do
      FactoryBot.create(:page, name: 'Contributors', path: 'Contributors.md', rebuild_id: rebuild.id)
      get :authors
      expect(response.body).to match(Author.last.display_name)
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
      get :index, params: { view: 'all' }
      expect(response).to render_template :index
    end

    it 'does not show preview resource' do
      preview = FactoryBot.create(:resource, publish: false, preview: true)
      get :index, params: { view: 'all' }
      expect(assigns(:resources)).not_to include(preview)
    end

    it 'displays pages' do
      FactoryBot.create_list(:resource, 150)
      get :search, params: { page: 1 }, xhr: true
      expect(response).to render_template :index
    end
  end

  describe 'using topics' do
    let(:topiced_resource) { FactoryBot.create(:resource, rebuild_id: rebuild.id) }
    let(:topic) { FactoryBot.create(:topic, rebuild_id: rebuild.id) }

    before do
      topiced_resource.topics << topic
    end

    it 'shows topiced resource' do
      get :index, params: { topic: topic.slug }

      expect(assigns(:resources)).to include(topiced_resource)
    end

    it 'does not show untopiced resource' do
      get :index, params: { topic: topic.slug }

      untopiced_resource = FactoryBot.create(:resource, rebuild_id: rebuild.id)
      expect(assigns(:resources)).not_to include(untopiced_resource)
    end

    it 'finds multiple resources' do
      get :index, params: { topic: topic.slug }

      expect(assigns(:resources).size).to be < 2
    end
  end

  describe 'using categories' do
    let(:category) { FactoryBot.create(:category, rebuild_id: rebuild.id) }
    let(:topic) { FactoryBot.create(:topic, category:, rebuild_id: rebuild.id) }
    let(:resource_with_category) { FactoryBot.create(:resource, rebuild_id: rebuild.id) }
    let(:resource_without_category) { FactoryBot.create(:resource, rebuild_id: rebuild.id) }

    before do
      resource_with_category.topics << topic
      get :index, params: { category: category.slug }
    end

    it 'shows the right resource' do
      expect(assigns(:resources)).to include(resource_with_category)
    end

    it 'does not show the wrong resource' do
      expect(assigns(:resources)).not_to include(resource_without_category)
    end
  end

  describe 'using authors' do
    let(:author) { FactoryBot.create(:author, rebuild_id: rebuild.id) }
    let(:resource_with_author) { FactoryBot.create(:resource, rebuild_id: rebuild.id) }

    it 'includes the right resource' do
      resource_with_author.authors << author
      get :index, params: { author: author.slug }
      expect(assigns(:resources)).to include resource_with_author
    end

    it 'does not include the wrong one' do
      resource_with_author.authors << author
      resource_without_author = FactoryBot.create(:resource, rebuild_id: rebuild.id)
      get :index, params: { author: author.slug }
      expect(assigns(:resources)).not_to include resource_without_author
    end
  end

  describe 'index' do
    before do
      10.times do
        FactoryBot.create(:resource, rebuild_id: RebuildStatus.displayed_rebuild.id, publish: true,
                                     published_at: rand(1..10).weeks.ago)
      end
      12.times do
        FactoryBot.create(:resource, published_at: 1.week.ago, rebuild_id: rebuild.id)
        FactoryBot.create(:resource, published_at: 2.weeks.ago, rebuild_id: rebuild.id)
      end
    end

    it 'is in alpha order' do
      old_resource = FactoryBot.create(:resource, published_at: 1.week.ago, name: 'AA', rebuild_id: rebuild.id)
      FactoryBot.create(:resource, published_at: 2.weeks.ago, rebuild_id: rebuild.id, name: 'CC')
      FactoryBot.create(:resource, published_at: Time.zone.today, name: 'BB', rebuild_id: rebuild.id)
      get :index
      expect(assigns(:resources).first).to eq old_resource
    end

    it 'gets by recent' do
      6.times { FactoryBot.create(:resource, published_at: rand(1..6).days.ago) }
      new_resource = FactoryBot.create(:resource, published_at: Time.zone.now, name: 'BB', rebuild_id: rebuild.id)
      get :index, params: { recent: 'true' }
      expect(assigns(:resources).first).to eq new_resource
    end

    it 'shows recent' do
      Resource.where(published_at: nil).find_each(&:destroy)
      get :index, params: { recent: 'true' }
      first_date = assigns(:resources).first.published_at
      second_date = assigns(:resources).last.published_at
      expect(first_date).to be_later_than second_date
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
