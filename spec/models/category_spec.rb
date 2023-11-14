# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  it 'can create itself from content' do
    content = "**Description:** Foo blah blah \n **Overview:** blah
\n\n baz --ban
**Topics:**
- **Fooble**
A fooble given a blah
\n<!---\n Category order: 2 \n--->"

    cat = RebuildStatus.displayed_rebuild.find_or_create_resource('Site/Topics/foo.md')
    cat.parse_and_update(content)
    expect(cat).to be_a(described_class)
    expect(cat.order_num).to eq 2
    topic = Topic.find_by(name: 'Fooble')
    expect(topic.overview).to match('fooble')
    expect(cat.topics).to include(topic)
  end
end
