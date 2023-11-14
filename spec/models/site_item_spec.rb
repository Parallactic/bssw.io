# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteItem, type: :model do
  let(:published) do
    FactoryBot.create(:resource, rss_date: Time.zone.today, published_at: Time.zone.today, aggregate: 'base')
  end
  let(:hidden) { FactoryBot.create(:resource, publish: false) }
  let(:cat) { FactoryBot.create(:category, name: 'bar') }
  let(:top) { FactoryBot.create(:topic, name: 'foo') }
  let(:second_resource) { FactoryBot.create(:resource) }
  let(:resource) { FactoryBot.create(:resource, aggregate: 'base') }

  it 'shows published stuff' do
    expect(described_class.published).to include(published)
  end

  it 'hides non published stuff' do
    expect(described_class.published).not_to include(hidden)
  end

  it 'deals with topics' do
    top.category = cat
    resource.topics << top
    expect(described_class.with_topic(top)).to include(resource)
  end

  it 'shows in category' do
    top.category = cat
    resource.topics << top

    expect(described_class.with_category(cat)).to include(resource)
  end

  it "doesn't show if it doesn't match category" do
    top.category = cat
    resource.topics << top

    expect(described_class.with_category(cat)).not_to include(second_resource)
  end
end
