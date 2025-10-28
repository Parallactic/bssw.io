# frozen_string_literal: true

FactoryBot.define do
  factory :quote do
    text { 'MyText' }
    author { 'MyString' }
  end
end
