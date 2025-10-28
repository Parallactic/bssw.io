# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author, type: :model do
  let(:author) { FactoryBot.create(:author, website: 'foobar') }

  it 'shows a number of blogs' do
    blog = FactoryBot.create(:blog_post, rebuild_id: RebuildStatus.displayed_rebuild.id)
    blog.authors << author
    expect(author.blog_listing).to match '1'
  end

  it 'shows an empty resource listing' do
    expect(author.resource_listing).to match '0'
  end

  it 'shows an event listing' do
    3.times do
      e = FactoryBot.create(:event, rebuild_id: RebuildStatus.displayed_rebuild.id)
      e.authors << author
    end
    expect(author.event_listing).to match '3'
  end

  it 'has correct website' do
    expect(author.website).to match 'foobar'
  end

  it 'updates from github' do
    author = FactoryBot.create(:author, website: 'http://github.com/clararaubertas')
    author.update_from_github
    expect(author.affiliation).to match('Para')
  end
end
