# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { (0...8).map { rand(65..90).chr }.join }
    path { (0...8).map { rand(65..90).chr }.join }
    additional_dates do
      [
        FactoryBot.build(:additional_date,
                         label: 'Start Date',
                         additional_date_values: [FactoryBot.build(:additional_date_value, date: 3.weeks.ago)]),
        FactoryBot.build(:additional_date,
                         label: 'End Date',
                         additional_date_values: [FactoryBot.build(:additional_date_value, date: 3.weeks.from_now)])
      ]
    end
    location { 'MyString' }
    aggregate { 'base' }
    website { 'MyString' }
    rebuild
    publish { true }
    type { 'Event' }
  end
end
