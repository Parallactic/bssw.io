# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlogPost, type: :model do
  before(:all) do
    r = Rebuild.create
    RebuildStatus.create(display_rebuild_id: r.id)
  end


  it "does do right track" do
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
Track: Deep dive
Publish: true

-->"
    FactoryBot.create(:category, name: 'Better Blah Blah')

    res = Rebuild.create.find_or_create_resource('Blog/FooPost.md')
    res.parse_and_update(content)
    res.reload

    expect(res.tracks.map(&:name)).to include('Deep Dive')
  end
  
  
  it 'can create itself from content' do
    content = "# Foo \n#### Publication date: Jan 1, 2017
\n#### Contributed by [Jane Does](https://github.com)\n \n bar
\n          
\n          
**Hero Image**
- ![foo](image.jpg)[bloo bloo]
\n
\n
<!--
Topics: \"first qutoe\", foo, bar, \"quoted, topic\", \"end quo\"
Categories: Blah Blah
Track: \"How to\"
Publish: true

-->"
    FactoryBot.create(:category, name: 'Better Blah Blah')

    res = Rebuild.create.find_or_create_resource('Blog/FooPost.md')
    expect(res).to be_a(described_class)

    res.parse_and_update(content)
    res.reload
    expect(res.content).to match 'bar'
    puts res.topics.map(&:name)
    expect(res.topics.map(&:name)).to include('Quoted, Topic')
    expect(res.topics.map(&:name)).to include('End Quo')
    expect(res.topics.map(&:name)).to include('First Qutoe')
    expect(res.tracks.map(&:name)).to include('How To')

    expect(res.categories).not_to be_empty
    expect(res.authors.map(&:last_name).to_s).to match 'Doe'
    expect(res.hero_image_caption).not_to be_nil
  end
end
