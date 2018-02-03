require 'spec_helper'
require 'byebug'

describe OmniAuth::Strategies::YahooAuth do
  let(:request) { double('Request', params: {}, cookies: {}, env: {}) }
  let(:app) do
    lambda do
      [200, {}, ['Hello.']]
    end
  end

  subject do
    OmniAuth::Strategies::YahooAuth.new(app, 'appid', 'secret', @options || {}).tap do |strategy|
      allow(strategy).to receive(:request) do
        request
      end
    end
  end

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe 'client_options' do
    it 'has correct site' do
      expect(subject.client.site).to eq('https://api.login.yahoo.com')
    end

    it 'has correct authorize_url' do
      expect(subject.client.options[:authorize_url]).to eq('https://api.login.yahoo.com/oauth2/request_auth')
    end

    it 'has correct token_url' do
      expect(subject.client.options[:token_url]).to eq('https://api.login.yahoo.com/oauth2/get_token')
    end
  end
end
