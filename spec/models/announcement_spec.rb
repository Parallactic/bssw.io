# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Announcement, type: :model do
  it 'can create itself from content' do
    content = "# BSSw Announcements for 2017

Announcement:
- [Blog post: Improve user confidence in your software updates](../../Articles/Blog/ImproveUserConfidenceInSwUpdates.md)
- Display dates: #{1.day.ago.strftime('%m/%d/%Y')}-#{1.day.from_now.strftime('%m/%d/%Y')} # #

Announcement:
- [Scientific Software Days Conference, April 27-28, 2017](../../Events/Conference.ScientificSoftwareDays17.md)
- Display dates: #{1.day.from_now.strftime('%m/%d/%Y')}-#{2.days.from_now.strftime('%m/%d/%Y')} #

Announcement:
- [2017 International Workshop on Software Engineering for Science, May 22, 2017](../../Events/Workshop.SE4Science17.md)
- Display dates: #{4.days.ago.strftime('%m/%d/%Y')}-#{2.days.ago.strftime('%m/%d/%Y')} # #

"
    described_class.import(content, FactoryBot.create(:rebuild).id)
    expect(described_class.count).to eq 3
    current_announcement = described_class.find_by(start_date: 1.day.ago)
    late_announcement = described_class.find_by(start_date: 1.day.from_now)
    early_announcement = described_class.find_by(start_date: 4.days.ago)
    expect(described_class.first.start_date).not_to be_nil
    expect(current_announcement).not_to be_nil
    expect(late_announcement).not_to be_nil
    expect(described_class.for_today).to include(current_announcement)
    expect(described_class.for_today).not_to include(early_announcement)
  end
end
