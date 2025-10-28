# frozen_string_literal: true

# display with bio info
class FellowLink < ApplicationRecord
  belongs_to :fellow, dependent: :destroy
end
