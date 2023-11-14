# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeaturedPost, type: :model do
  it 'might have an image' do
    fp = FactoryBot.create(:featured_post, path: 'image.jpg')
    expect(fp).to be_image
    expect(fp.image).to be_a String
  end

  it 'might have a site item' do
    item = FactoryBot.create(:site_item, rebuild_id: RebuildStatus.first.display_rebuild_id, base_path: 'Item.md')
    fp = FactoryBot.create(:featured_post, path: item.base_path.to_s)
    expect(fp.site_item.id).to eq item.id
  end
end
