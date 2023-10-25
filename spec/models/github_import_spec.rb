# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkdownUtility, type: :model do
  it 'provides a fully qualified path' do
    path = 'http://example.com/image.jpg'
    modified_path = MarkdownUtility.modified_path(path)
    expect(modified_path).to match('http://example.com/image.jpg')
  end

  it 'provides an adjusted path' do
    path = 'foo.jpg'
    modified_path = MarkdownUtility.modified_path(path)
    expect(modified_path).to match('/main/images/foo.jpg')
  end

  it 'maintains subdirectories' do
    path = '../images/foo/foo.jpg'
    modified_path = MarkdownUtility.modified_path(path)
    expect(modified_path).to match('/main/images/foo/foo.jpg')
  end
end
