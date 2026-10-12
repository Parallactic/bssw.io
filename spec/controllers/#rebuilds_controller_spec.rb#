RSpec.describe RebuildsController, type: :controller do
  describe '#branch' do
    it 'is main outside the preview environment' do
      expect(controller.send(:branch)).to eq 'main'
    end

    it 'is preview in the preview environment' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('preview'))
      expect(controller.send(:branch)).to eq 'preview'
    end
  end
end
