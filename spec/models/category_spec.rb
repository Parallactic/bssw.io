# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:content) do
    "**Description:** Foo blah blah \n **Overview:** blah
\n\n baz --ban
**Topics:**
- **Fooble**
A fooble given a blah
\n<!---\n Category order: 2 \n--->"
  end
  let(:cat) do
    RebuildStatus.displayed_rebuild.find_or_create_resource('Site/Topics/foo.md')
  end

  let(:topic) { Topic.find_by(name: 'Fooble') }

  it 'can create itself from content' do
    cat.parse_and_update(content)
    expect(cat).to be_a(described_class)
  end

  it 'has an order number' do
    cat.parse_and_update(content)
    expect(cat.order_num).to eq 2
  end

  it 'gets the topic overview' do
    cat.parse_and_update(content)
    expect(topic.overview).to match('fooble')
  end

  it 'attaches the topic to the category' do
    cat.parse_and_update(content)
    expect(cat.topics).to include(topic)
  end
end
