# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RebuildsController, type: :controller do
  before(:all) do
    @min_site_item_count = 100
    @community_count = 6
    @topic_slug = 'revision-control'
    @how_to_slug = 'version-control-with-git-in-cse-projects'
    @what_is_slug = 'what-is-revision-control'
    @category_name = 'Better Development'
    @blog_post_slug = 'improve-user-confidence-in-your-software-updates'
    @author_slug = 'https://github.com/curfman'
    @search_expectations = { 'integration testing' => 57,
                             'testing' => 80,
                             'elaine' => 10,
                             'riley' => 1,
                             'c++' => 1 }
  end

  describe 'post import' do
    it 'tracks '
    it 'does some imports' do
      name = Rails.application.credentials[:import][:name]
      pw = Rails.application.credentials[:import][:password]
      @request.env['HTTP_AUTHORIZATION'] =
        "Basic #{Base64.encode64("#{name}:#{pw}")}"
      FactoryBot.create(:site_item)
      FactoryBot.create(:author)
      post :import

      puts "errors: #{Rebuild.last.errors_encountered}"

      puts "collis: #{Rebuild.last.slug_collisions}"
      puts "pub: #{Rebuild.last.unpublished_files}"

      # these are specific checks to our resource library...
      # using variables defined at top of this file
      expect(SiteItem.count).to be > @min_site_item_count
      #      expect(RebuildStatus.first.display_rebuild_id).to eq Rebuild.last.id
      expect(SiteItem.last.rebuild_id).to eq RebuildStatus.first.display_rebuild_id
      expect(SiteItem.displayed.count).to be > @min_site_item_count
      expect(Community.displayed.count).to eq @community_count

      expect(Community.first.resources).not_to be_empty
      topic = Topic.displayed.where(slug: @topic_slug).first
      wi = SearchResult.displayed.find(@what_is_slug)
      expect(wi.topics).to include topic
      expect(topic.site_items).to include wi
      expect(topic.site_items).to include SiteItem.displayed.find_by(slug: @how_to_slug)
      expect(topic.category).to eq Category.displayed.find_by(
        name: @category_name
      )

      expect(Fellow.all).not_to be_empty
      expect(Fellow.all.map(&:fellow_links).flatten).not_to be_empty
      expect(Fellow.all.map(&:honorable_mention).flatten.include?(true)).to be true
      expect(Fellow.first.name).not_to be_blank
      expect(Fellow.first.long_bio).not_to be_blank

      expect(BlogPost.find_by(slug: @blog_post_slug)).to be_a BlogPost

      expect(BlogPost.find_by(slug: @blog_post_slug).related_posts.size).to eq 5
      expect(Quote.all).not_to be_empty
      expect(Announcement.all).not_to be_empty
      expect(FeaturedPost.displayed.first.site_item || FeaturedPost.displayed.first.image).not_to be_nil
      # Announcement.displayed.each do |a|
      #   expect(a.site_item).not_to be_nil
      # end
      expect(Author.displayed.where(website: 'https://github.com/nniiicc').first.last_name).not_to eq 'Nic'
      expect(Page.find('homepage')).to be_a Page
      expect(Page.find('homepage').snippet).not_to be_empty

      expect(Author.displayed.where(website: @author_slug).size).to eq 1
      expect(Page.displayed.where(name: 'Contributors')).not_to be_empty

      expect(Author.displayed.where(website: @author_slug).first.resource_listing).not_to eq '0 resources'

      puts 'tracks: ....'
      SiteItem.displayed.each do |si|
        unless si.tracks.empty?
          puts si.tracks.map(&:name)
          puts si.base_path
        end
      end

      expect(Staff.displayed.select do |a|
               a.website.try(
                 :match?, 'maherou'
               )
             end.first.affiliation).to eq 'Sandia National Laboratories'
      expect(Author.displayed.select do |a|
               a.website.try(
                 :match?, 'maherou'
               )
             end.first.affiliation).to eq "Sandia National Labs and St. John's University"

      expect(Category.displayed.first.slug).to eq 'better-planning'

      expect(SiteItem.displayed.last.topic_list).not_to be_empty
      expect(Event.where(
        base_path: '2021-10-wosss21.md'
      ).first.start_at.to_date).to eq Date.parse('October 6 2021').to_date
      expect(Event.where(
        base_path: '2021-10-wosss21.md'
      ).first.end_at.to_date).to eq Date.parse('October 8 2021').to_date
      puts SiteItem.displayed.all.map(&:tracks).flatten.map(&:inspect)
      # expect do
      #   post :import
      # end.not_to change(Rebuild, :count)
      puts response.inspect
      Fellow.displayed.each { |f| puts "#{f.slug} #{f.name}" }

      expect(response).to redirect_to('/rebuilds?rebuilt=true')
    end

    it 'can check rebuilds' do
      name = Rails.application.credentials[:import][:name]
      pw = Rails.application.credentials[:import][:password]
      credentials = ActionController::HttpAuthentication::Basic.encode_credentials name, pw
      request.env['HTTP_AUTHORIZATION'] = credentials
      build = Rebuild.create(
        started_at: 1.minute.ago, ended_at: nil
      )
      RebuildStatus.first.update_attribute(
        :in_progress_rebuild_id, build.id
      )
      post :import
      expect(response).to redirect_to('/rebuilds')
    end
  end

  describe 'index' do
    it 'gets index' do
      name = Rails.application.credentials[:import][:name]
      pw = Rails.application.credentials[:import][:password]
      credentials = ActionController::HttpAuthentication::Basic.encode_credentials name, pw
      request.env['HTTP_AUTHORIZATION'] = credentials
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'does not get index w/o pw' do
      credentials = ActionController::HttpAuthentication::Basic.encode_credentials 'bssw',
                                                                                   'wrong'
      request.env['HTTP_AUTHORIZATION'] =
        credentials
      get :index
      expect(response).not_to have_http_status(:success)
    end
  end

  describe 'make displayed' do
    it 'changes the current id' do
      3.times { Rebuild.create }
      rs = RebuildStatus.first
      rs ||= RebuildStatus.find_or_create_by(display_rebuild_id: Rebuild.first.id)
      credentials = ActionController::HttpAuthentication::Basic.encode_credentials 'bssw',
                                                                                   'rebuildlog'
      request.env['HTTP_AUTHORIZATION'] =
        credentials
      expect(Rebuild.first.id).not_to eq rs.display_rebuild_id
      expect do
        post :make_displayed,
             params: { id: Rebuild.first.id }
        rs.reload
      end.to change(rs,
                    :display_rebuild_id)
    end
  end
end
