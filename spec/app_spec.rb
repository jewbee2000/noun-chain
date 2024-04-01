# spec/app_spec.rb

require 'rspec'
require 'rack/test'
require_relative '../wordchain.rb'

describe 'Wordchain Web App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should allow accessing the home page" do
    get '/'
    expect(last_response).to be_ok
  end

  # Add more tests as needed
end
