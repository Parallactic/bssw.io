# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Quote, type: :model do
  let(:content) { "- Foo --bar \n- baz --ban" }

  it 'matches content text' do
    described_class.import(content)
    expect(described_class.find_by(text: 'Foo ').author).to match 'bar'
  end

  it 'matches content author' do
    described_class.import(content)
    expect(described_class.find_by(author: 'ban').text).to match 'baz'
  end
end
