# frozen_string_literal: true

# view helpers
module ApplicationHelper
  def listings(author)
    [(author.resource_listing if author.resource_listing != '0 resources'),
     (author.blog_listing if author.blog_listing != '0 blog posts'),
     (author.event_listing if author.event_listing != '0 events')].delete_if(&:nil?).join(', ')
  end

  def search_result_url(result)
    case result
    when SiteItem
      site_item_url(result)
    when Author
      site_items_url(author: result.slug)
    when Fellow
      fellow_url(result)
    end
  end

  def social_title
    return @post.name if @post
    return @page.name if @page
    return @event.name if @event
    return @resource.name if @resource
  end

  def social_image
    return @post.open_graph_image_tag if @post
    return @event.open_graph_image_tag if @event
    return @page.open_graph_image_tag if @page
    return @resource.open_graph_image_tag if @resource.respond_to?(:open_graph_image_tag)
  end

  def social_description
    return strip_tags(@post.snippet) if @post
    return strip_tags(@page.snippet) if @page
    return strip_tags(@event.snippet) if @event
    return strip_tags(@resource.snippet) if @resource
  end

  def author_list(resource)
    resource.author_list.html_safe
  end

  def author_list_without_links(resource)
    resource.author_list_without_links.html_safe
  end

  def formatted_additionals(event)
    used_dates = []
    event.special_additional_dates.map do |date|
      if used_dates.include?(date.additional_date)
        val = ''
      else
        val = "<strong>#{date.additional_date.label.titleize}</strong> " +
              date.additional_date.additional_date_values.map { |adv| date_range(adv.date, nil) }.join('; ')
      end
      used_dates << date.additional_date
      val
    end
  end

  def formatted_standard_dates(event)
    [if event.start_at.blank?
       ''
     else
       (event.end_at.blank? ? '<strong>Date</strong>' : '<strong>Dates</strong>') + date_range(
         event.start_at, event.end_at
       ).to_s.html_safe
     end]
  end

  def show_dates(event)
    (formatted_standard_dates(event) + formatted_additionals(event)
    ).delete_if(&:blank?).join('<br />').html_safe
  end

  def show_date(date_value)
    date = date_value.additional_date
    if date.label == 'Start Date'
      date_range(date.event.start_at,
                 date.event.end_at).to_s.html_safe
    else
      date_range(date_value.date, nil).to_s.html_safe

    end
  end

  def show_label(date_value)
    date = date_value.additional_date
    if date.label == 'Start Date'
      date_value.event.end_at.blank? ? 'Event Date' : 'Event Dates'
    else
      date.label
    end
  end

  def date_range(start_at, end_at)
    return unless start_at

    start_date = start_at.strftime('%b %e, %Y')
    return start_date.html_safe if start_at == end_at || !end_at

    start_date = start_at.strftime('%b %e') if start_at.year == end_at.year
    end_date = if end_at.month == start_at.month
                 end_at.strftime('%-d, %Y')
               else
                 end_at.strftime('%b %e, %Y')
               end
    "#{start_date}&ndash;#{end_date}".html_safe
  end

  def show_page(path, next_page)
    if path.match(/page/)
      path.gsub(/page.?\d+/, "page=#{next_page}").html_safe
    else
      (path + "?&page=#{next_page}").html_safe
    end
  end
end
