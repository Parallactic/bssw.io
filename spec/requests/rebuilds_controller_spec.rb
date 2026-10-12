# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RebuildsController, type: :request do
  let(:credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials Rails.application.credentials[:import][:name],
                                                                   Rails.application.credentials[:import][:password]
  end

  let(:rs) do
    RebuildStatus.first ||
      RebuildStatus.find_or_create_by(display_rebuild_id: Rebuild.first.id)
  end

  describe 'expected imports' do
    let(:min_site_item_count) { 100 }
    let(:community_count) { 6 }
    let(:topic_slug) { 'revision-control' }
    let(:how_to_slug) { 'version-control-with-git-in-cse-projects' }
    let(:what_is_slug) { 'what-is-revision-control' }
    let(:category_name) { 'Better Development' }
    let(:blog_post_slug) do
      'improve-user-confidence-in-your-software-updates'
    end
    let(:author_slug) { 'https://github.com/curfman' }
    let(:search_expectations) do
      { 'integration testing' => 57,
        'testing' => 80,
        'elaine' => 10,
        'riley' => 1,
        'c++' => 1 }
    end

    describe 'post import' do
      before(:all) do
        username = Rails.application.credentials[:import][:name]
        pw = Rails.application.credentials[:import][:password]
        require 'stackprof'
        StackProf.run(mode: :wall, out: 'tmp/import.dump', interval: 1000) do
          post '/rebuilds/import', headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(username, pw) }
        end

        puts "status=#{response.status} location=#{response.location.inspect}"
        puts response.body[0, 500]
      end

      it 'does some imports' do
        # these are specific checks to our resource library...
        # using variables defined at top of this file
        expect(SiteItem.count).to be > min_site_item_count
        #      expect(RebuildStatus.first.display_rebuild_id).to eq Rebuild.last.id
        expect(SiteItem.last.rebuild_id).to eq RebuildStatus.first.display_rebuild_id
        expect(SiteItem.displayed.count).to be > min_site_item_count
      end

      it 'has communities' do
        expect(Community.displayed.count).to eq community_count

        expect(Community.first.resources).not_to be_empty
      end

      it 'does topics and searches' do
        topic = Topic.displayed.where(slug: topic_slug).first
        wi = SearchResult.displayed.find(what_is_slug)
        expect(wi.topics).to include topic
        expect(topic.site_items).to include wi
        expect(topic.site_items).to include SiteItem.displayed.find_by(slug: how_to_slug)
        expect(topic.category).to eq Category.displayed.find_by(
          name: category_name
        )
      end

      it 'finds fellows' do
        expect(Fellow.all).not_to be_empty
        expect(Fellow.all.map(&:fellow_links).flatten).not_to be_empty
        expect(Fellow.all.map(&:honorable_mention).flatten.include?(true)).to be true
        expect(Fellow.first.name).not_to be_blank
        expect(Fellow.first.long_bio).not_to be_blank
      end

      it 'finds blog posts' do
        expect(BlogPost.find_by(slug: blog_post_slug)).to be_a BlogPost

        expect(BlogPost.find_by(slug: blog_post_slug).related_posts.size).to eq 5
      end

      it 'finds misc' do
        expect(Quote.all).not_to be_empty
        expect(Announcement.all).not_to be_empty
        expect(FeaturedPost.displayed.first.site_item || FeaturedPost.displayed.first.image).not_to be_nil
      end

      it 'changes author name' do
        expect(Author.displayed.where(website: 'https://github.com/nniiicc').first.last_name).not_to eq 'Nic'
        expect(Author.displayed.where(website: author_slug).size).to eq 1
      end

      it 'makes pages' do
        expect(Page.find('homepage')).to be_a Page
        expect(Page.find('homepage').snippet).not_to be_empty

        expect(Page.displayed.where(name: 'Contributors')).not_to be_empty
      end

      it 'alphabetizes' do
        expect(Author.displayed.where(website: 'https://github.com/npch').first.alphabetized_name).to eq 'Chue'
      end

      it 'does other stuff' do
        expect(Author.displayed.where(website: author_slug).first.resource_listing).not_to eq '0 resources'

        expect(Staff.displayed.select do |a|
                 a.website.try(
                   :match?, 'maherou'
                 )
               end.first.affiliation).to eq 'Sandia National Laboratories'
        expect(Author.displayed.select do |a|
                 a.website.try(
                   :match?, 'maherou'
                 )
               end.first.affiliation).to match "ParaTools, Inc; St. John's University, MN; HPE; Hyperion"

        expect(Category.displayed.first.slug).to eq 'better-planning'
        expect(BlogPost.displayed.last.topics).not_to be_empty
        expect(BlogPost.displayed.last.topic_list).not_to be_empty
        expect(Event.where(
          base_path: '2021-10-wosss21.md'
        ).first.start_at.to_date).to eq Date.parse('October 6 2021').to_date
        expect(Event.where(
          base_path: '2021-10-wosss21.md'
        ).first.end_at.to_date).to eq Date.parse('October 8 2021').to_date

        # expect(response).to redirect_to('/rebuilds?rebuilt=true')
      end

      it 'can check rebuilds' do
        username = Rails.application.credentials[:import][:name]
        pw = Rails.application.credentials[:import][:password]
        build = Rebuild.create(
          started_at: 1.minute.ago, ended_at: nil
        )
        RebuildStatus.first.update(
          in_progress_rebuild_id: build.id
        )
        post '/rebuilds/import', headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(username, pw) }
        expect(response).to redirect_to('/rebuilds')
      end
    end

    describe 'index' do
      before do
        rs
      end

      it 'gets index' do
        get '/rebuilds', headers: { 'HTTP_AUTHORIZATION' => credentials }
        expect(response).to have_http_status(:success)
      end

      it 'does not get index w/o pw' do
        bad_credentials = ActionController::HttpAuthentication::Basic.encode_credentials 'bssw',
                                                                                         'wrong'

        get '/rebuilds', headers: { 'HTTP_AUTHORIZATION' => bad_credentials }

        expect(response).not_to have_http_status(:success)
      end
    end

    describe 'make displayed' do
      before do
        3.times { Rebuild.create }
      end

      it 'changes the current id' do
        status = rs
        new_r = Rebuild.create
        puts "status #{rs.inspect} new #{new_r.inspect}"
        expect do
          post "/rebuilds/#{new_r.id}/make_displayed", headers: { 'HTTP_AUTHORIZATION' => credentials }
          status.reload
        end.to change(status, :display_rebuild_id)
      end
    end
  end
end
