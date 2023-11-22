# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Announcement, type: :model do
  let(:content) do
    "# BSSw Announcements for 2017

Announcement:
- [Blog post: Improve user confidence in your software updates](../../Articles/Blog/ImproveUserConfidenceInSwUpdates.md)
- Display dates: #{1.day.ago.strftime('%m/%d/%Y')}-#{1.day.from_now.strftime('%m/%d/%Y')} # #

Announcement:
- [Scientific Software Days Conference, April 27-28, 2017](../../Events/Conference.ScientificSoftwareDays17.md)
- Display dates: #{1.day.from_now.strftime('%m/%d/%Y')}-#{2.days.from_now.strftime('%m/%d/%Y')} #

Announcement:
- [2017 International Workshop on Software Engineering for Science, May 22, 2017](../../Events/Workshop.SE4Science17.md)
- Display dates: #{4.days.ago.strftime('%m/%d/%Y')}-#{2.days.ago.strftime('%m/%d/%Y')} # #"
  end

  before do
    described_class.import(content, FactoryBot.create(:rebuild).id)
  end

  it 'gets multiple announcements from the page' do
    expect(described_class.count).to eq 3
  end

  it "shows today's announcements" do
    current_announcement = described_class.find_by(start_date: 1.day.ago)
    expect(described_class.for_today).to include(current_announcement)
  end

  it "doesn't show future announcements" do
    late_announcement = described_class.find_by(start_date: 1.day.from_now)
    expect(described_class.for_today).not_to include(late_announcement)
  end

  it "doesn't show past announcements" do
    early_announcement = described_class.find_by(start_date: 4.days.ago)
    expect(described_class.for_today).not_to include(early_announcement)
  end
end
