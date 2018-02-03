# OmniAuth Yahoo OAuth2 Strategy
[![Gem Version](https://badge.fury.io/rb/omniauth-yahoo_auth.svg)](https://badge.fury.io/rb/omniauth-yahoo_auth)

Yahoo OAuth2 Strategy for OmniAuth. <br>
Supports OAuth 2.0 client-side flow. Read about it at: https://developer.yahoo.com/oauth2/guide/

## Installation

Add to your `Gemfile`:

```ruby
gem 'omniauth-yahoo_auth'
```

Then `bundle install`.

## Yahoo App Setup
* Go to https://developer.yahoo.com/apps/
* Click on `Create an app`. Give an application name, callback domain and Api Permissions.
* This gem is tested with an app that had contacts and profiles API enabled with read access.
* Then hit create app button.
* Yahoo will now give you your app's id and secret.

## Usage

* Add a route `get 'auth/:provider/callback',  to: 'sessions#custom'` in your routes.rb file
* Create a sessions controller and a custom method.
* Add the following in one of your initializer files or create a new one(say config/initializers/omniauth.rb)
```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :yahoo_auth, ENV['YAHOO_APP_ID'], ENV['YAHOO_APP_SECRET']
end
```
* You can now restart your server and go to `/auth/yahoo_auth`.
* Yahoo should now prompt the user to login using yahoo credentials. Enter them and hit login.
* You should be able to get access to an Auth hash using `env["omniauth.auth"]` inside your session#custom method.

**NOTE**: While developing your application, if you change the scope in the initializer you will need to restart your app server.

## Configuring

You can configure several options, which you pass in to the `provider` method via a `Hash`:

Option name | Default | Explanation
--- | --- | ---
`name` | `yahoo_auth` | It can be changed to any value, for example `yahoo`. The OmniAuth URL will thus change to /auth/yahoo .
`redirect_uri` | `/auth/yahoo/callback` | Specify a custom callback URL used during the server-side flow. Default is `https://www.your_callback_domain/auth/yahoo/callback`
`image_size` | `192x192` | Set the size for the returned image in the auth hash. Valid options include sizes: 16x16, 24x24, 32x32, 48x48, 64x64, 96x96, 128x128, 192x192

For example:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :yahoo_auth, ENV['YAHOO_APP_ID'], ENV['YAHOO_APP_SECRET'],
  { name: "yahoo",
    redirect_uri: "https://www.your_callback_domain/auth/yahoo/callback",
    image_size: "96x96"}
end
```

## Auth Hash

Here's an example *Auth Hash* available in `request.env['omniauth.auth']`:

```ruby
{
  info: {
    nickname: 'Harvey',
    email: 'harvey@suits.com',
    first_name: 'Harvey',
    last_name: 'Specter',
    image: 'https://s.yimg.com/wm/modern/images/default_user_profile_pic_192.png',
  },
  credentials: {
    token: 'HnEU9cep1...', # OAuth 2.0 ACCESS_TOKEN.
    refresh_token: 'AFBTm...', # REFRESH_TOKEN to to get a new OAuth 2.0 access_token when the previous one expires.
    expires_at: 1503232413, # Time at which your OAuth 2.0 access_token expires.
    expires: true # this will always be true.
  },
  extra: {
      gender: 'M',
      language: 'en-IN',
      location: 'User Location',
      birth_year: 'User birth year',
      birth_date: 'User birth date',
      addresses: 'User addresses',
      urls: {
        default_image: 'https://s.yimg.com/wm/modern/images/default_user_profile_pic_192.png',
        profile: 'http://profile.yahoo.com/KBA...'
      }
  }
}
```

The precise information available will depend on your request.

## Integration with Devise

First define your application id and secret in `config/initializers/devise.rb`. Do not use the snippet mentioned in the [Usage](https://github.com/creative-karan/omniauth-yahoo_auth#usage) section.

Configuration options can be passed as the last parameter here as key/value pairs.

```ruby
config.omniauth :yahoo_auth, 'YAHOO_APP_ID', 'YAHOO_APP_SECRET', {}
```

Then add the following to 'config/routes.rb' so the callback routes are defined.

```ruby
devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
```

Make sure your model is omniauthable. Generally this is "/app/models/user.rb"

```ruby
devise :omniauthable, omniauth_providers: [:yahoo_auth]
```

Then make sure your callbacks controller is setup.

```ruby
# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def yahoo_auth
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Yahoo'
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.yahoo_data'] = request.env['omniauth.auth']
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
  end
end
```

and bind to or create the user

```ruby
# app/models/user.rb
def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first
    # Uncomment the section below if you want users to be created if they don't exist
    # unless user
    #     user = User.create(name: data['nickname'],
    #        email: data['email'],
    #        password: Devise.friendly_token[0,20]
    #     )
    # end
    user
end
```

For your views you can login using:

```erb
<%= link_to "Sign in with Yahoo", user_yahoo_auth_omniauth_authorize_path %>

<%# Devise prior 4.1.0: %>
<%= link_to "Sign in with Yahoo", user_omniauth_authorize_path(:yahoo_auth) %>
```

## Test this gem locally
Yahoo doesn't allow `localhost or 127.0.0.1` as callback domain while making an app. <br>
So, you can follow below steps to test this gem on your local environment.

* In case you are using unix or linux system, create a alias like `127.0.0.1 mywebsite.dev` in /etc/hosts
 (you need have the line which is similar to the one mentioned here in the file)
* Use http://website.dev/callbackurl/for/app in call back URL during local testing.
* You will need to run your rails app at port 80.
* To forcefully run your app on port 80 use `rvmsudo rails s -p 80`

## Further Reading
* Authorization flow of yahoo is described at : https://developer.yahoo.com/oauth2/guide/flows_authcode/.
* Yahoo social api documentation : https://developer.yahoo.com/social/rest_api_guide/
* Overview of devise and OAuth gems working together : https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/creative-karan/omniauth-yahoo_auth. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
