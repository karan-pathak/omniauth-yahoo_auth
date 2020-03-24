require 'omniauth-oauth2'
require 'base64'

module OmniAuth
  module Strategies
    class YahooAuth < OmniAuth::Strategies::OAuth2
      USER_INFO_API = 'https://api.login.yahoo.com/openid/v1/userinfo'

      option :name, 'yahoo_auth'

      option :client_options, {
        site: 'https://api.login.yahoo.com',
        authorize_url: 'https://api.login.yahoo.com/oauth2/request_auth',
        token_url: 'https://api.login.yahoo.com/oauth2/get_token'
      }

      uid do
        access_token.params['xoauth_yahoo_guid']
      end

      info do
        prune!(
          nickname: raw_info['preferred_username'],
          email: raw_info['email'],
          first_name: raw_info['given_name'],
          last_name: raw_info['family_name'],
          image: raw_info['picture'],
        )
      end

      extra do
        prune!(
          sub: raw_info['sub'],
          name: raw_info['name'],
          middle_name: raw_info['middle_name'],
          nickname: raw_info['nickname'],
          gender: raw_info['gender'],
          language: raw_info['locale'],
          website: raw_info['website'],
          birth_date: raw_info['birthdate'],
          zone_info: raw_info['zoneinfo'],
          updated_at: raw_info['updated_at'],
          email_verified: raw_info['email_verified'],
          address: raw_info['address'],
          phone_number: raw_info['phone_number'],
          phone_number_verified: raw_info['phone_number_verified'],
        )
      end

      def raw_info
        @raw_info ||= access_token.get(USER_INFO_API).parsed
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

      def custom_build_access_token
        get_access_token(request)
      end
      alias build_access_token custom_build_access_token

      private

      def callback_url
        options[:redirect_uri] || "#{full_host}#{script_name}#{callback_path}"
      end

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end

      def get_access_token(request)
        credentials = "#{options.client_id}:#{options.client_secret}"
        auth = "Basic #{Base64.strict_encode64(credentials)}"

        client.get_token(
          {
            redirect_uri: callback_url,
            code: request.params['code'],
            grant_type: 'authorization_code',
            headers: { 'Authorization' => auth }
          }.merge(token_params.to_hash(symbolize_keys: true)),
          deep_symbolize(options.auth_token_params || {}),
        )
      end
    end
  end
end
