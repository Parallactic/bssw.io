# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  render_views

  it 'has a robot' do
    get 'robots'
    expect(response.body).to match('test robot')
  end
end
