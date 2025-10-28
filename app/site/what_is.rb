# frozen_string_literal: true

# level 0 content
class WhatIs < Resource
  # extend FriendlyId
  # friendly_id :name, use: [:finders, :history]
  #  before_save :update_categories

  def update_from_content(updated_content, rebuild)
    super(updated_content, rebuild)
    self.type = 'WhatIs'
    save
  end
end
