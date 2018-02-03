require 'omniauth-oauth2'
require 'base64'

module OmniAuth
  module Strategies
    # Main class for Yahoo Auth Startegy
    class YahooAuth < OmniAuth::Strategies::OAuth2
      SOCIAL_API_URL = 'https://social.yahooapis.com/v1/user/'

      option :name, 'yahoo_auth'

      option :client_options, {
        site: 'https://api.login.yahoo.com',
        authorize_url: 'https://api.login.yahoo.com/oauth2/request_auth',
        token_url: 'https://api.login.yahoo.com/oauth2/get_token'
      }

      uid { access_token.params['xoauth_yahoo_guid'] }

      info do
        prune!(
          nickname: raw_info['nickname'],
          email: get_primary_email,
          first_name: raw_info['givenName'],
          last_name: raw_info['familyName'],
          image: get_user_image
        )
      end

      extra do
        prune!(
          gender: raw_info['gender'],
          language: raw_info['lang'],
          location: raw_info['location'],
          birth_year: raw_info['birthYear'],
          birth_date: raw_info['birthdate'],
          addresses: raw_info['addresses'],
          urls: {
            default_image: raw_info['image']['imageUrl'],
            profile: raw_info['profileUrl']
          }
        )
      end

      def raw_info
        # This is a public API and does not need signing or authentication
        raw_info_url = "#{SOCIAL_API_URL}#{uid}/profile?format=json"
        @raw_info ||= access_token.get(raw_info_url).parsed['profile'] || {}
        rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

      def custom_build_access_token
        get_access_token(request)
      end
      alias build_access_token custom_build_access_token

      private

      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end

      def get_primary_email
        email = nil
        email_hash = raw_info['emails']
        if email_hash
          email_info = email_hash.find{|e| e['primary']} || email_hash.first
          email = email_info['handle']
        end
        email
      end

      def get_user_image
        image_size = options[:image_size]
        if image_size
          image_url = "#{SOCIAL_API_URL}#{uid}/profile/image/#{image_size}?format=json"
          image_hash = access_token.get(image_url).parsed["image"] || {}
          image_hash["imageUrl"]
        else
          # Return default image
          raw_info['image']['imageUrl']
        end
      end

      def get_access_token(request)
        verifier = request.params['code']
        auth = "Basic #{Base64.strict_encode64("#{options.client_id}:#{options.client_secret}")}"
        token = client.get_token(
          { redirect_uri: callback_url,
            code: verifier,
            grant_type: 'authorization_code',
            headers: { 'Authorization' => auth }
          }.merge(token_params.to_hash(symbolize_keys: true)),
          deep_symbolize(options.auth_token_params || {})
        )
        token
      end

    end
  end
end
