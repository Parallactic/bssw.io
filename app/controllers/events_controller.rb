# frozen_string_literal: true

# show past and upcoming events
class EventsController < ApplicationController
  def index
    filter_events
    @last_page = (@events.size.to_f / 25).ceil
    @current_page = (params[:page] || 1).to_i
    if params[:view] == 'all'
      @events = @events.paginate(page: 1, per_page: @events.size)
      @last_page = @current_page = 1
    else
      per_page = @current_page * 25
      @events = @events.paginate(page: 1, per_page:)
    end
  end

  def show
    @event = scoped_resources.events.find(params[:id])
    @resource = @event
  end

  private

  # def set_cache_key
  #   last_modified_str = Event.order(:updated_at).last.updated_at.utc.to_fs(:number)
  #   @cache_key = "#{params[:past]}/all_events/#{last_modified_str}"
  # end

  def filter_events
    author = params[:author]
    events = Event.displayed.published
    if author
      @events = events.with_author(Author.displayed.find(author))
    else
      filter_events_by_time(events)
    end
    @events = @events.distinct
  end

  def filter_events_by_time(events)
    #    set_cache_key
    @page = Page.find_by_name('Upcoming Events')
    @page = Page.find_by_name('Past Events') if params[:past]

    @events = @upcoming_events = events.upcoming
    return unless params[:past]

    @events = @past_events = events.past
  end
end
