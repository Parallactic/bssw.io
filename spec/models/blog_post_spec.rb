# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlogPost, type: :model do
  before(:all) do
    r = Rebuild.create
    RebuildStatus.create(display_rebuild_id: r.id)
  end

  it 'can create itself from content' do
    content = "# Foo \n#### Publication date: Jan 1, 2017
\n#### Contributed by [Jane Does](https://github.com)\n \n bar
\n
\n
**Hero Image**
- ![fo](image.jpg) [bloo bloo]
\n
\n
<!--
Topics: \"first qutoe\", foo, bar, \"quoted, topic\", \"end quo\"
Categories: Blah Blah
Publish: true

-->"
    FactoryBot.create(:category, name: 'Better Blah Blah')

    res = Rebuild.create.find_or_create_resource('Blog/FooPost.md')
    expect(res).to be_a(described_class)

    res.parse_and_update(content)
    res.reload
    expect(res.content).to match 'bar'
    puts res.topics.map(&:name)
    expect(res.topics.map(&:name)).to include('quoted, topic')
    expect(res.topics.map(&:name)).to include('end quo')
    expect(res.topics.map(&:name)).to include('first qutoe')
    expect(res.categories).not_to be_empty
    expect(res.authors.map(&:last_name).to_s).to match 'Doe'
    expect(res.hero_image_caption).not_to be_nil
  end
end
