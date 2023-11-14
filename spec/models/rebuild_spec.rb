# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rebuild, type: :model do
  it 'exists' do
    expect(described_class.new).to be_a(described_class)
  end
end
