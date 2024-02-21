# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeaturedPost, type: :model do
  before do
    build = Rebuild.create
    RebuildStatus.create(display_rebuild_id: build.id)
  end

  it 'might have an image' do
    fp = FactoryBot.create(:featured_post, path: 'image.jpg')
    expect(fp.image).to match('jpg')
  end

  it 'might have a site item' do
    item = FactoryBot.create(:site_item, rebuild_id: RebuildStatus.first.display_rebuild_id,
                                         base_path: 'SomeKindaItem.md')
    fp = FactoryBot.create(:featured_post, path: item.base_path.to_s)

    expect(fp.site_item.id).to eq item.id
  end
end
