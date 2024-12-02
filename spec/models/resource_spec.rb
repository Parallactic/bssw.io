# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resource, type: :model do
  let(:res) { Rebuild.create.find_or_create_resource('stuff/CuratedContent/foo.md') }

  before do
    FactoryBot.create(:page, name: 'Resources')
    FactoryBot.create(:page, path: 'foo.md')
    content = "# Foo \n#### Contributed by [Jane Does](https://github.com)\n \n bar
\n#### Publication Date: June 1, 2020
![bloo](blah.jpg)[okay]

<img src='blaj.jpg' class='lightbox'>

[fooble](foo.md)

<!---
Topics: foo, bar
Categories: Blah Blah
Publish: yes
Aggregate: Base
RSS update: 01-01-18
--->"

    FactoryBot.create(:category, name: 'Better Blah Blah')
    res.parse_and_update(content)
    res.reload
  end

  it 'gets an appropriate path name' do
    expect(res.path).to eq 'CuratedContent/foo.md'
  end

  it 'gets the title' do
    expect(res.name).to eq 'Foo'
  end

  it 'gets content' do
    expect(res.content).to match 'bar'
  end

  it 'parses topics' do
    expect(res.topics).not_to be_empty
  end

  it 'parses categories' do
    expect(res.categories).not_to be_empty
  end

  it 'parses authors' do
    expect(res.authors.map(&:last_name).to_s).to match 'Doe'
  end

  it 'can update links and images' do
    res.update_links_and_images
    expect(res.content).to match 'caption'
  end
end
