# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Page, type: :model do
  it 'can create itself from content' do
    content = "# Foo \n#### Publication date: Jan 1, 2017
\n#### Contributed by [Jane Does](https://github.com)\n \n bar
## Team
[Foo bar](foooby)
<!---
Topics: foo, bar
Categories: Blah Blah
Publish: true

--->"
    @rebuild = Rebuild.create
    RebuildStatus.all.each(&:destroy)
    RebuildStatus.create(display_rebuild_id: @rebuild.id)

    res = @rebuild.find_or_create_resource('Site/Homepage.md')
    expect(res).to be_a(described_class)
    res.parse_and_update(content)
    res.reload
    expect(res.content).to match 'bar'
    expect(res.name).to match 'Foo'
    expect(res.home?).to eq true
    expect(described_class.names_to_pages(['Foo'])).to include(res)
  end
end
