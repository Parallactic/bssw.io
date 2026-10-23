require 'rails_helper'

RSpec.describe MarkdownUtility, type: :model do
  describe '.resolve_link' do
    it 'returns the original path when nothing matches' do
      expect(described_class.resolve_link('/no/such/path-xyz')).to eq('/no/such/path-xyz')
    end
  end

  describe '.update_link' do
    before { allow(described_class).to receive(:resolve_link).with('/a').and_return('/x') }

    it 'resolves every time outside a cache block' do
      2.times { expect(described_class.update_link('/a')).to eq('/x') }
      expect(described_class).to have_received(:resolve_link).twice
    end

    it 'resolves a path once inside with_link_cache' do
      described_class.with_link_cache do
        2.times { expect(described_class.update_link('/a')).to eq('/x') }
      end
      expect(described_class).to have_received(:resolve_link).once
    end
  end
end
