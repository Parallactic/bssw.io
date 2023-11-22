# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Community, type: :model do
  let(:community) { Rebuild.create.find_or_create_resource('stuff/Site/Communities/foo.md') }

  describe 'with some content...' do
    before do
      FactoryBot.create(:resource, base_path: 'itspath.md')
      content = "# Foo \n#### Contributed by [Jane Does](https://github.com)\n \n bar\n
<!-- Featured resources: -->
- [A Resource](/itspath.md)
<!---
Topics  : foo, bar
Categories: Blah Blah
Publish: true
Aggregate: Base
--->"

      community.parse_and_update(content)
    end

    it 'has the right path' do
      expect(community.path).to eq 'Site/Communities/foo.md'
    end

    it 'has the right name' do
      expect(community.name).to eq 'Foo'
    end

    it 'updates resources' do
      expect(community.resources).not_to be_empty
    end
  end
end
