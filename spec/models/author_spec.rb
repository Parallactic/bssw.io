# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author, type: :model do
  it 'shows listings' do
    author = FactoryBot.create(:author, website: 'foobar')
    expect(author.resource_listing).to match '0'
    expect(author.blog_listing).to match '0'
    expect(author.event_listing).to match '0'
    expect(author.website).to match 'foobar'
  end

  it 'updates from github' do
    author = FactoryBot.create(:author, website: 'http://github.com/clararaubertas')
    author.update_from_github
    expect(author.affiliation).to match('Para')
  end
end
