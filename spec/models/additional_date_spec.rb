# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdditionalDate, type: :model do
  it 'exists' do
    event = FactoryBot.create(:event)
    date = FactoryBot.create(:additional_date,
                             additional_date_values:
                               [FactoryBot.build(:additional_date_value,
                                                 date: 1.week.ago)],
                             label: 'Date',
                             event_id: event.id)

    expect(date).to be_valid
  end

  describe 'additional date values' do
    event = FactoryBot.create(:event)

    past1 = FactoryBot.create(:additional_date,
                              additional_date_values:
                                [FactoryBot.build(:additional_date_value, date: 1.week.ago)],
                              label: 'Date',
                              event_id: event.id)
    past2 = FactoryBot.create(:additional_date,
                              additional_date_values:
                                [FactoryBot.build(:additional_date_value,
                                                  date: 2.weeks.ago)],
                              label: 'Date',
                              event:)
    past3 = FactoryBot.create(:additional_date,
                              additional_date_values:
                                [FactoryBot.build(:additional_date_value,
                                                  date: 3.weeks.ago)], label: 'Date', event:)
    future1 = FactoryBot.create(:additional_date,
                                additional_date_values:
                                  [FactoryBot.build(:additional_date_value,
                                                    date: 1.week.from_now)], label: 'Date', event:)
    future2 = FactoryBot.create(:additional_date,
                                additional_date_values:
                                  [FactoryBot.build(:additional_date_value,
                                                    date: 2.weeks.from_now)],
                                label: 'Date', event_id: event.id)
    future3 = FactoryBot.create(:additional_date,
                                additional_date_values:
                                  [FactoryBot.build(:additional_date_value,
                                                    date: 3.weeks.from_now)],
                                label: 'Date', event_id: event.id)
    pasts = [past1, past2, past3]
    futures = [future1, future2, future3]
    it 'gets past dates' do
      dates = AdditionalDateValue.get_from_events(Event.all, true)
      expect(dates.sort).to eq(pasts.sort)
    end

    it 'gets past without future' do
      dates = AdditionalDateValue.get_from_events(Event.all, true)
      expect(dates).not_to include(future3)
    end

    it 'gets future dates' do
      dates = AdditionalDateValue.get_from_events(Event.all, false)
      expect(dates.sort).to eq(futures.sort)
    end

    it 'gets future without past' do
      dates = AdditionalDateValue.get_from_events(Event.all, false)
      expect(dates).not_to include(past3)
    end
  end
end
