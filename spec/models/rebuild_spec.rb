# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rebuild, type: :model do


  describe '#record_errors' do
    it 'appends the file name, message and backtrace to errors_encountered' do
      rebuild = Rebuild.create!
      error = begin
        raise StandardError, 'bad file'
      rescue StandardError => e
        e   # raised, so it has a backtrace
      end

      rebuild.send(:record_errors, 'foo.md', error)

      expect(rebuild.reload.errors_encountered).to include('foo.md', 'bad file')
    end
  end

  
  it 'removes stale records and their join rows' do
    old = Rebuild.create!(created_at: 1.year.ago)
    5.times do
      Rebuild.create(created_at: 5.months.ago)
    end
    puts "num of rebuilds: #{Rebuild.count}"
    keep = Rebuild.create!
    topic = FactoryBot.create(:topic, rebuild: old)
    item = FactoryBot.create(:resource, rebuild: old)   
    item.topics << topic

    keep.clear_old

    expect(Rebuild.exists?(old.id)).to be false
    expect(SearchResult.exists?(item.id)).to be false
    expect(Topic.exists?(topic.id)).to be false
    expect(ActiveRecord::Base.connection.select_value(
      "SELECT COUNT(*) FROM site_items_topics WHERE site_item_id = #{item.id}"
    )).to eq 0
  end
end
