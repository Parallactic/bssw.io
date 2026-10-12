# frozen_string_literal: true

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  render_views

  let(:rebuild) { RebuildStatus.displayed_rebuild }

  before do
    #    RebuildStatus.all.find_each(&:destroy)
    RebuildStatus.find_or_create_by(display_rebuild_id: Rebuild.first.id)
  end

  describe 'get index' do
    describe 'future events' do
      before do
        FactoryBot.create(:page, name: 'Upcoming Events', rebuild_id: rebuild.id)
      end

      it 'shows future' do
        event = FactoryBot.create(:event, publish: true, rebuild_id: rebuild.id)
        doc = Nokogiri::XML('<ul><li>Dates: December 10 - January 10 </li></ul>')
        event.send(:update_dates, doc.css("li:contains('Dates:')"))
        get :index
        expect(assigns(:events)).to include(event)
      end
    end

describe 'past events' do
  before do
    FactoryBot.create(:page, name: 'Past Events', rebuild_id: rebuild.id)
  end

  it 'shows past by page' do
    26.times do
      event = FactoryBot.create(:event, publish: true, rebuild_id: rebuild.id)
      date = FactoryBot.create(:additional_date, label: 'Party Date', event_id: event.id)
      FactoryBot.create(:additional_date_value, additional_date: date, date: 1.week.ago)
    end

    get :index, params: { past: true, page: 1 }
    expect(assigns(:events).to_a.size).to eq 25

    get :index, params: { past: true, page: 2 }
    expect(assigns(:events).to_a.size).to be > 25

  end

  it 'shows past' do
    event = FactoryBot.create(:event, rebuild:)
    AdditionalDate.make_date('some date', 1.day.ago.to_s, event)
    get :index, params: { past: true }
    expect(assigns(:events)).to include(event)
  end
end

    it 'gets by author' do
      author = FactoryBot.create(:author, rebuild_id: rebuild.id)
      event = FactoryBot.create(:event, publish: true, rebuild_id: rebuild.id)
      event.authors << author
      get :index, params: { author: author.slug }
      expect(response.body).to include(event.name)
    end

    it 'can update dates' do
      event = FactoryBot.create(:event, publish: true, rebuild_id: rebuild.id)
      doc = Nokogiri::XML('<ul><li>Dates: January 10 - January 10</li></ul>')
      event.send(:update_dates, doc.css("li:contains('Dates:')"))

      event.save
      expect(Event.displayed.published).to include(event)
    end

    it 'gets unpaginated' do
      get :index, params: { view: 'all' }
      expect(response.body).not_to be_blank
    end
  end

  describe 'get show' do
    it 'shows an event' do
      event = FactoryBot.create(:event, publish: true, rebuild_id: rebuild.id)
      AdditionalDate.make_date('Submission Date', 1.week.from_now.to_s, event)
      AdditionalDate.make_date('Party Date', 2.weeks.from_now.to_s, event)
      get :show, params: { id: event }
      expect(response.body).to match('Party')
    end

    it 'shows an event without end date' do
      event = FactoryBot.create(:event, publish: true, rebuild_id: rebuild.id)
      event.additional_dates.select { |d| d.label == 'End Date' }.each(&:destroy)
      AdditionalDate.make_date('Submission Date', 1.week.from_now.to_s, event)
      AdditionalDate.make_date('Party Date', 2.weeks.from_now.to_s, event)
      get :show, params: { id: event }
      expect(response.body).to match('Party')
    end

    it 'shows an event with a different date range' do
      event = FactoryBot.create(:event,
                                additional_dates: [
                                  FactoryBot.build(:additional_date,
                                                   label: 'Start Date',
                                                   additional_date_values:
                                                     [FactoryBot.build(:additional_date_value,
                                                                       date: Time.zone.today.change(
                                                                         month: 6, day: 1
                                                                       ))]),
                                  FactoryBot.build(:additional_date,
                                                   label: 'End Date',
                                                   additional_date_values:
                                                     [FactoryBot.build(:additional_date_value,
                                                                       date: Time.zone.today.change(month: 6,
                                                                                                    day: 10))]),
                                  FactoryBot.build(:additional_date,
                                                   label: 'Other Date',
                                                   additional_date_values:
                                                     [FactoryBot.build(:additional_date_value, date: 1.week.from_now)])
                                ],
                                rebuild_id: rebuild.id)
      get :show, params: { id: event }
      expect(response.body).to include('Other')
    end
  end
end
