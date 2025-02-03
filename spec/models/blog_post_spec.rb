# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlogPost, type: :model do
  let(:content) do
    "# Foo \n#### Publication date: Jan 1, 2017
\n#### Contributed by [Jane Does](https://github.com)\n \n bar
\n
\n
**Hero Image**
- ![fo](image.jpg) [bloo bloo]
\n
\n
<!--
Topics: \"First Qutoe\", Foo, Bar, \"Quoted, Topic\", \"End Quo\"
Categories: Blah Blah
Track: Deep dive, community
Publish: true

-->"
  end

  let(:res) { Rebuild.create.find_or_create_resource('Blog/FooPost.md') }

  before do
    r = Rebuild.create
    RebuildStatus.create(display_rebuild_id: r.id)
    FactoryBot.create(:category, name: 'Better Blah Blah')
    res.parse_and_update(content)
  end

  it 'gets content' do
    expect(res.content).to match 'bar'
  end

  it 'gets quoted topics' do
    expect(res.topics.map(&:name)).to include('Quoted, Topic')
  end

  it 'gets quoted topics at end of list' do
    expect(res.topics.map(&:name)).to include('End Quo')
  end

  it 'gets quoted topic at beginning of list' do
    expect(res.topics.map(&:name)).to include('First Qutoe')
  end

  it 'gets categories' do
    expect(res.categories).not_to be_empty
  end

  it 'gets authors' do
    expect(res.authors.map(&:last_name).to_s).to match 'Doe'
  end

  it 'gets caption' do
    expect(res.hero_image_caption).not_to be_nil
  end

  it 'gets tracks' do

    expect(res.tracks.size).to eq 2
  end

  
end
