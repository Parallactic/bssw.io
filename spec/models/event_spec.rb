# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  it 'can create itself from content' do
    content = "# Foo \n bar
        \n* Dates: December 3, #{Date.today.year} - January 5
        \n* Location: Place \n* \n* <!--- Publish: Yes --->"

    rebuild = FactoryBot.create(:rebuild)
    event = rebuild.find_or_create_resource('stuff/Events/foo.md')
    expect(event).to be_a(Event)
    expect(event.path).to eq 'Events/foo.md'
    event.parse_and_update(content)
    event.reload
    event.update_attribute(:publish, true)
    expect(event.name).to eq 'Foo'
    expect(event.content).to match 'bar'
    expect(event.start_at).not_to be_nil
    expect(event.start_at).to be < event.end_at
    expect(event.end_at).to be > Date.today
    expect(event.location).to match 'Place'
    #    expect(Event.past).not_to include(event)
    expect(Event.upcoming).to include(event)
  end

  it 'can create itself from content' do
    content = "# Foo \n bar
        \n* Dates: December 3, #{Date.today.year} - January 5
        \n* Submission Date: November 1, #{Date.today.year}
        \n* Poster Dates: November 2 2021 - November 3 2021
        \n* Party dates: June 3 2022; July 4 2022
        \n* Location: Place \n* \n* <!--- Publish: Yes --->"
    event = Rebuild.create.find_or_create_resource('stuff/Events/foo.md')
    event.parse_and_update(content)
    event.reload
    expect(event.additional_dates).not_to be_empty
    expect(
      event.additional_dates.map(&:additional_date_values).flatten.map(&:date).flatten
    ).to include(Chronic.parse('July 4 2022').to_date)
  end

  it 'can parse written dates' do
    content = "# Foo \n bar
    \n* Dates: 10-9-18 - 1-25-19
    \n* Location: Place \n* \n* <!--- Publish: Yes --->"

    event = Rebuild.create.find_or_create_resource('Events/foo.md')
    event.parse_and_update(content)
    expect(event.start_at).to eq Chronic.parse('October 9 2018').to_date
  end

  it 'can parse dates from earlier this year' do
    content = "# Foo \n bar
    \n* Dates: February 1 - March 2 #{Date.today.year}
    \n* Location: Place \n* \n* <!--- Publish: Yes --->"

    event = Rebuild.create.find_or_create_resource('Events/foo.md')
    event.parse_and_update(content)
    expect(event.start_at.to_date).to eq Chronic.parse("February 1 #{Date.today.year}").to_date
  end

  it 'can parse dates from later this year' do
    content = "# Foo \n bar
    \n* Dates: December 1 - December 20 #{Date.today.year}
    \n* Location: Place \n* \n* <!--- Publish: Yes --->"
    event = Rebuild.create.find_or_create_resource('Events/foo.md')
    event.parse_and_update(content)
    expect(event.start_at.to_date).to eq Chronic.parse("December 1 #{Date.today.year}").to_date
  end

  it 'can parse dates across years' do
    content = "# Foo \n bar
     \n* Dates: December 1 - January 2
     \n* Location: Place \n* \n* <!--- Publish: Yes --->"

    event = Rebuild.create.find_or_create_resource('Events/foo.md')
    event.parse_and_update(content)

    expect(event.start_at).to eq Chronic.parse("December 1 #{Date.today.year}").to_date
    expect(event.end_at).to eq Chronic.parse("January 2 #{Date.today.year + 1}").to_date
  end
end
