# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Community, type: :model do
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

      @community = Rebuild.create.find_or_create_resource('stuff/Site/Communities/foo.md')
      @community.parse_and_update(content)
    end

    it 'can create itself from content' do
      expect(@community).to be_a(described_class)
      expect(@community.path).to eq 'Site/Communities/foo.md'
      expect(@community.name).to eq 'Foo'
    end

    it 'updates resources' do
      expect(@community.resources).not_to be_empty
    end
  end
end
