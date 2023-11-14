# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactForm, type: :model do
  it 'exists' do
    cont = described_class.new(name: 'foo', email: 'foo@example.com')
    expect(cont.headers.to_s).to match 'Contact'
  end
end
