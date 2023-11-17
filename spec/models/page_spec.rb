# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Page, type: :model do
  let(:content) do
    "# Foo \n#### Publication date: Jan 1, 2017
\n#### Contributed by [Jane Does](https://github.com)\n \n bar
## Team
[Foo bar](foooby)
<!---
Topics: foo, bar
Categories: Blah Blah
Publish: true

--->"
  end

  let(:res) { Page.last }
  

  before do
    resource = Rebuild.create.find_or_create_resource('Site/Homepage.md')
    RebuildStatus.first.update(display_rebuild_id: resource.rebuild.id)

    resource.parse_and_update(content)
  end

  it 'can create itself from content' do

    expect(res).to be_a(described_class)
  end

  it 'fills in content' do
    expect(res.content).to match 'bar'
  end

  it 'has a name' do
    expect(res.name).to match 'Foo'
  end

  it 'picks out homepage' do
    expect(res.home?).to eq true
  end

  it 'is in menu list' do
    expect(described_class.names_to_pages(['Foo'])).to include(res)
  end
end
