# frozen_string_literal: true

FactoryBot.define do
  factory :what_is, class: 'WhatIs' do
    path { (0...8).map { rand(65..90).chr }.join }
    content { 'MyText' }
    name { 'MyString' }
  end
end
