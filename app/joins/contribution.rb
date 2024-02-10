# frozen_string_literal: true

class Contribution < ApplicationRecord
  belongs_to :author, dependent: :destroy
  belongs_to :site_item, dependent: :destroy

  def link
    "<a class='author' href='/items?author=#{author.slug}'>#{display_name} </a>"
  end

  def self.clean
    all.find_each do |c|
      c.destroy if c.author.nil? || c.site_item.nil?
    end
  end
end
