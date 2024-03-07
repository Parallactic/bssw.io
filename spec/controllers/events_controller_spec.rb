# frozen_string_literal: true

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  render_views

  let(:rebuild) { RebuildStatus.displayed_rebuild }

  before do
    RebuildStatus.all.find_each(&:destroy)
    RebuildStatus.create(display_rebuild_id: Rebuild.create.id)
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
        200.times do
          event = FactoryBot.create(:event, publish: true, rebuild_id: rebuild.id)
          doc = Nokogiri::XML('<ul><li>Dates: January 1 2019 - January 10 2019</li></ul>')
          event.send(:update_dates, doc.css("li:contains('Dates:')"))
          10.times do
            event.additional_dates.first.additional_date_values << FactoryBot.create(
              :additional_date_value,
              date: 1.week.ago,
              additional_date: event.additional_dates.first
            )
          end
        end
      end

      it 'shows past by page' do
        get :index, params: { past: true, page: 5 }

        expect(assigns(:events)).not_to be_nil
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
      expect(assigns(:event)).to eq event
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
      expect(assigns(:event)).not_to be_nil
    end
  end
end
