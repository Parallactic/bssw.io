# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:rebuild) { FactoryBot.create(:rebuild) }
  let(:event) { rebuild.find_or_create_resource('stuff/Events/foo.md') }
  let(:additional_content) do
    "# Foo \n bar
        \n* Dates: December 3, #{Time.zone.today.year} - January 5
        \n* Submission Date: November 1, #{Time.zone.today.year}
        \n* Poster Dates: November 2 2021 - November 3 2021
        \n* Party dates: June 3 2022; July 4 2022
        \n* Location: Place \n* \n* <!--- Publish: Yes --->"
  end

  before do
    content = "# Foo \n bar
        \n* Dates: December 3, #{Time.zone.today.year} - January 5
        \n* Location: Place \n* \n* <!--- Publish: Yes --->"
    event.parse_and_update(content)
  end

  it 'can create itself from content' do
    expect(event.content).to match 'bar'
  end

  it 'has a path' do
    expect(event.path).to eq 'Events/foo.md'
  end

  it 'parses name' do
    expect(event.name).to eq 'Foo'
  end

  it 'has a start time' do
    expect(event.start_at).to be < event.end_at
  end

  it 'has an end time' do
    expect(event.end_at).to be > Time.zone.today
  end

  it 'has a location' do
    expect(event.location).to match 'Place'
  end

  it 'is upcoming' do
    expect(described_class.upcoming).to include(event)
  end

  it 'can have additional dates' do
    event.parse_and_update(additional_content)
    expect(
      event.additional_dates.map(&:additional_date_values).flatten.map(&:date).flatten
    ).to include(Chronic.parse('July 4 2022').to_date)
  end

  it 'can parse written dates' do
    content = "# Foo \n bar
    \n* Dates: 10-9-18 - 1-25-19
    \n* Location: Place \n* \n* <!--- Publish: Yes --->"

    event.parse_and_update(content)
    expect(event.start_at).to eq Chronic.parse('October 9 2018').to_date
  end

  it 'can use the [date] label' do
    content = "# Foo \n bar
    \n* [date] Q&A: 01-02-2025
    \n* Location: Place \n* \n* <!--- Publish: Yes --->"

    my_event = rebuild.find_or_create_resource('stuff/Events/webinar.md')
    my_event.parse_and_update(content)

    expect(my_event.additional_dates.first.label).to eq 'Q&amp;A'
  end

  it 'can parse dates from earlier this year' do
    content = "# Foo \n bar
    \n* Dates: February 1 - March 2 #{Time.zone.today.year}
    \n* Location: Place \n* \n* <!--- Publish: Yes --->"

    event.parse_and_update(content)
    expect(event.start_at.to_date).to eq Chronic.parse("February 1 #{Time.zone.today.year}").to_date
  end

  it 'can parse dates from later this year' do
    content = "# Foo \n bar
    \n* Dates: December 1 - December 20 #{Time.zone.today.year}
    \n* Location: Place \n* \n* <!--- Publish: Yes --->"

    event.parse_and_update(content)
    expect(event.start_at.to_date).to eq Chronic.parse("December 1 #{Time.zone.today.year}").to_date
  end

  describe 'parsing dates across years' do
    before do
      content = "# Foo \n bar
     \n* Dates: December 1 - January 2
     \n* Location: Place \n* \n* <!--- Publish: Yes --->"

      event.parse_and_update(content)
    end

    it 'starts this year' do
      expect(event.start_at).to eq Chronic.parse("December 1 #{Time.zone.today.year}").to_date
    end

    it 'ends next year' do
      expect(event.end_at).to eq Chronic.parse("January 2 #{Time.zone.today.year + 1}").to_date
    end
  end
end
