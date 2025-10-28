# frozen_string_literal: true

xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title 'BSSw Resource Feed'
    xml.description 'All Resources'
    xml.link site_items_url

    @resources.each do |resource|
      xml.item do
        xml.title resource.name
        xml.description { |xml| xml.cdata!(resource.content.to_s) }
        xml.pubDate resource.rss_date.try(:to_formatted_s, :rfc822)
        xml.link site_item_url(resource)
        xml.guid resource.slug.to_s + resource.rss_date.to_s
      end
    end
  end
end
