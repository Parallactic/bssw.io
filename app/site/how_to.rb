# frozen_string_literal: true

# level 0 content
class HowTo < Resource
  # extend FriendlyId
  # friendly_id :name, use: [:finders, :history]

  def update_from_content(updated_content, rebuild)
    super(updated_content, rebuild)
    self.type = 'HowTo'
    save
  end
end
