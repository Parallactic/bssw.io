# frozen_string_literal: true

# base class
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
