# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdditionalDate, type: :model do
  let(:date) do
    FactoryBot.create(:additional_date,
                      additional_date_values:
                        [FactoryBot.build(:additional_date_value,
                                          date: 1.week.ago)],
                      label: 'Date', event_id: FactoryBot.create(:event).id)
  end

  it 'exists' do
    expect(date).to be_valid
  end

  # it 'has values' do
  #   event = FactoryBot.create(:event)

  #   FactoryBot.create(:additional_date,
  #                     additional_date_values:
  #                       [FactoryBot.build(:additional_date_value, date: 1.week.ago)],
  #                     label: 'Date',
  #                     event_id: event.id)
  #   FactoryBot.create(:additional_date,
  #                     additional_date_values:
  #                       [FactoryBot.build(:additional_date_value,
  #                                         date: 2.weeks.ago)],
  #                     label: 'Date',
  #                     event:)
  #   FactoryBot.create(:additional_date,
  #                     additional_date_values:
  #                       [FactoryBot.build(:additional_date_value,
  #                                         date: 3.weeks.ago)], label: 'Date', event:)
  #   FactoryBot.create(:additional_date,
  #                     additional_date_values:
  #                       [FactoryBot.build(:additional_date_value, date: 1.week.from_now)], label: 'Date', event:)
  #   FactoryBot.create(:additional_date,
  #                     additional_date_values:
  #                       [FactoryBot.build(:additional_date_value,
  #                                         date: 2.weeks.from_now)],
  #                     label: 'Date', event_id: event.id)
  #   FactoryBot.create(:additional_date,
  #                     additional_date_values:
  #                       [FactoryBot.build(:additional_date_value,
  #                                         date: 3.weeks.from_now)],
  #                     label: 'Date', event_id: event.id)

  # pasts = AdditionalDateValue.get_from_events(Event.all, true)

  # futures = AdditionalDateValue.get_from_events(Event.all, false)
  #  end
end
