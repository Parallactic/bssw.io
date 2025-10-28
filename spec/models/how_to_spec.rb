# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HowTo, type: :model do
  let(:res) { Rebuild.create.find_or_create_resource('CuratedContent/HowToFoo.md') }

  before do
    content = "# Foo \n#### Contributed by [Jane Does](https://github.com)\n
\n#### Publication Date: May 1, 2020 \n bar
<!---
Topics: foo, bar
Categories: Blah Blah
Publish: true
Aggregate: Base
--->"
    FactoryBot.create(:category, name: 'Better Blah Blah')
    res.parse_and_update(content)
    res.reload
  end

  it 'is a How To' do
    expect(res).to be_a(described_class)
  end

  it 'parses content' do
    expect(res.content).to match 'bar'
  end

  it 'gets topics' do
    expect(res.topics).not_to be_empty
  end

  it 'gets categories' do
    expect(res.categories).not_to be_empty
  end

  it 'gets authors' do
    expect(res.authors.map(&:last_name).to_s).to match 'Doe'
  end
end
