# frozen_string_literal: true

# view helpers
module ApplicationHelper
  def listings(author)
    safe_join([(author.resource_listing if author.resource_listing != '0 resources'),
     (author.blog_listing if author.blog_listing != '0 blog posts'),
     (author.event_listing if author.event_listing != '0 events')].delete_if(&:nil?), ', ')
  end

  def search_result_url(result)
    case result
    when SiteItem
      site_item_url(result)
    when Author
      site_items_url(author: result.slug)
    when Fellow
      fellow_url(result)
    when Page
      page_url(result)
    end
  end

  def social_image(page_item)
    page_item.open_graph_image_tag if page_item.respond_to?(:open_graph_image_tag)
  end

  def author_list(resource)
    resource.author_list
  end

  def author_list_without_links(resource)
    resource.author_list_without_links
  end

  def formatted_additionals(event)
    used_dates = []
    event.special_additional_dates.map do |date|
      additional = date.additional_date
      if used_dates.include?(additional)
        ''
      else
        used_dates << additional
        content_tag('strong', additional.label) +
          additional.additional_date_values.map { |adv| date_range(adv.date, nil) }.join('; ')
      end
    end
  end

  def formatted_standard_dates(event)
    return [''] if event.start_at.blank?

    [(if event.end_at.blank?
        content_tag('strong', event.start_date.label.gsub('Start', ''))
      else
        content_tag('strong', event.start_date.label.gsub('Start', '').pluralize)
      end), date_range(
        event.start_at, event.end_at
      )]
  end

  def show_dates(event)
    safe_join((formatted_standard_dates(event) + formatted_additionals(event)
    ).delete_if(&:blank?), '<br />'.html_safe)
  end

  def show_date(date_value)
    date = date_value.additional_date
    if date.label =~ /Start/ || date.label =~ /End/
      date_range(date.event.start_at,
                 date.event.end_at)
    else
      date_range(date_value.date, nil)
    end
  end

  def show_label(date_value)
    date = date_value.additional_date
    label = date.label
    label = label.gsub('Start ', '') if date.label.match('Start')
    label = label.gsub('End ', '') if date.label.match('End')
    #    label = label.gsub(/s$/, '') if date.label.match(/Dates$/)
    label
  end

  def date_range(start_at, end_at)
    return unless start_at

    start_date = start_at.strftime('%b %e, %Y')
    return start_date if start_at == end_at || !end_at

    start_date = start_at.strftime('%b %e') if start_at.year == end_at.year
    end_date = if end_at.month == start_at.month
                 end_at.strftime('%-d, %Y')
               else
                 end_at.strftime('%b %e, %Y')
               end
    safe_join([start_date, '&ndash;'.html_safe, end_date])
  end

  def show_page(path, next_page)
    if path.match(/page/)
      path.gsub(/page.?\d+/, "page=#{next_page}")
    else
      safe_join([path], "?&page=#{next_page}".html_safe)
    end
  end
end
