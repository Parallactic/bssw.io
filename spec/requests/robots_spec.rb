# spec/requests/robots_spec.rb
require 'rails_helper'

RSpec.describe 'Robots', type: :request do
  it 'has a robot' do
    get '/robots.txt' # use whatever path `bin/rails routes | grep robots` shows
    expect(response.body).to match('test robot')
  end
end
