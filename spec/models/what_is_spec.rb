# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WhatIs, type: :model do
  let(:what_is) { Rebuild.create.find_or_create_resource('CuratedContent/WhatIsFoo.md') }

  before do
    content = "# Foo \n#### Contributed by [Jane Does](https://github.com)\n \n bar
\n# ### Publication Date: May 1, 2020
<!--    -
Topics:         first topic, second topic
Categories: Blah Blah
Publish: true
Aggregate: Base
--->"
    FactoryBot.create(:category, name: 'Better Blah Blah')
    what_is.parse_and_update(content)
  end

  it 'is basic' do
    expect(what_is.basic?).to be true
  end

  it 'has content' do
    expect(what_is.content).to match 'bar'
  end
end
