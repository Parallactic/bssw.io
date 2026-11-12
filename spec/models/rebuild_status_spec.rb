# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RebuildStatus, type: :model do
  it 'has the code branch set by the suite setup, as deploy would' do
    expect(described_class.code_branch).to eq TEST_CODE_BRANCH
  end

  it 'stores the code branch on the status record' do
    described_class.code_branch = 'some-feature'
    expect(described_class.first.reload.code_branch).to eq 'some-feature'
  end

  it 'keeps the code branch when a rebuild starts' do
    described_class.start(Rebuild.create, 'preview')
    expect(described_class.code_branch).to eq TEST_CODE_BRANCH
  end
end
