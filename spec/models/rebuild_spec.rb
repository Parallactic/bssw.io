# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rebuild, type: :model do
  describe '#record_errors' do
    it 'appends the file name, message and backtrace to errors_encountered' do
      rebuild = described_class.create!
      error = begin
        raise StandardError, 'bad file'
      rescue StandardError => e
        e # raised, so it has a backtrace
      end

      rebuild.send(:record_errors, 'foo.md', error)

      expect(rebuild.reload.errors_encountered).to include('foo.md', 'bad file')
    end

    describe '#process_file' do
      it 'records the error and carries on when a file fails to process' do
        rebuild = described_class.create!
        file = double(full_name: 'repo/Articles/Foo.md', read: '')
        allow(rebuild).to receive(:process_path).and_raise(StandardError, 'bad file')

        expect { rebuild.send(:process_file, file) }.not_to raise_error
        expect(rebuild.reload.errors_encountered).to include('Foo.md', 'bad file')
      end
    end
  end

  describe 'removes stale records and their join rows' do
    
    let(:old) { described_class.create!(created_at: 1.year.ago) }
    let(:item) { FactoryBot.create(:resource, rebuild: old) }
    let(:topic) { FactoryBot.create(:topic, rebuild: old) } 
    before do
    
      5.times do
        described_class.create(created_at: 5.months.ago)
      end
      puts "num of rebuilds: #{described_class.count}"
      keep = described_class.create!


      item.topics << topic

      keep.clear_old
    end

    it "doesn't keep the old build" do
      expect(described_class.exists?(old.id)).to be false
    end

    it "doesn't keep the old search result" do
      expect(SearchResult.exists?(item.id)).to be false
    end

    it "doesn't keep the old topic" do
      expect(Topic.exists?(topic.id)).to be false
    end

    it 'clears the join table' do
      expect(ActiveRecord::Base.connection.select_value(
               "SELECT COUNT(*) FROM site_items_topics WHERE site_item_id = #{item.id}"
             )).to eq 0
    end
  end
end
