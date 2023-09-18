# frozen_string_literal: true

# joins for authors + site items
class Contribution < ApplicationRecord
  belongs_to :author, dependent: :destroy
  belongs_to :site_item, dependent: :destroy

  def link
    "<a class='author' href='/items?author=#{author.slug}'>#{display_name}</a>"
  end
end
