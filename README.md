# auto-session-timeout 
## with bootstrap modals for warning and timeout messages

Provides automatic session timeout in a Rails application with bootstrap
styled modals for warning and timeout messages.
This provides a warning modal at a given time, and then does not redirect the user immediately to the log in screen, rather, it
puts up another modal that explains to the user that their session has expired.
If you don't want a warning message before session timeout please find the auto session timeout gem here
 
https://github.com/pelargir/auto-session-timeout
 
Very easy to install and configure. Have you ever wanted to force your users
off your app if they go idle for a certain period of time? Many
online banking sites use this technique. If your app is used on any
kind of public computer system, this plugin is a necessity.

***
This version is using a Devise specific path: `/users/sign_in`. Please overwrite the `render_session_timeout` action
if not using Devise.
***
## Installation

Add this line to your application's Gemfile:

    gem 'auto-session-timeout', git: 'https://github.com/ahay-agile6/auto-session-timeout.git'

And then execute:

    $ bundle


## Usage
### Add jQuery and jQuery UI
Add jquery and bootstrap 4+ on your application.js file, set the current_user helper method in application controller if its not yet defined

After installing, tell your application controller to use auto timeout:

    class ApplicationController < ActionController::Base
      auto_session_timeout 1.hour
      before_timedout_action
    end

You will also need to insert this line inside the body tags in your
views. The easiest way to do this is to insert it once inside your
default or application-wide layout. Make sure you are only rendering
it if the user is logged in, otherwise the plugin will attempt to force
non-existent sessions to timeout, wreaking havoc:

    <body>
      <% if current_user %>
        <%= auto_session_warning_tag %>
        <%= auto_session_timeout_js %>
      <% end %>
    </body>

You need to setup two actions: one to return the session status and
another that runs when the session times out. You can use the default
actions included with the plugin by inserting this line in your target
controller (most likely your user or session controller):

    class SessionsController < ApplicationController
      auto_session_timeout_actions
    end

To customize the default actions, simply override them. You can call
the render_session_status and render_session_timeout methods to use
the default implementation from the plugin, or you can define the
actions entirely with your own custom code:

    class SessionsController < ApplicationController
      def active
       render_session_status
      end
      
      def timeout
        render_session_timeout
      end
    end

In any of these cases, make sure to properly map the actions in
your `routes.rb` file:

    match 'active'  => 'sessions#active',  via: :get
    match 'timeout' => 'sessions#timeout', via: :get

***
## For applications using Devise:
Let's say the scope for devise is `user`:
Generate the controllers for devise/user:

`rails generate devise:controllers user`

Then, in `routes.rb`:

```
  devise_for :users, controllers: { sessions: "users/sessions" }

  devise_scope :user do
    match 'active'            => 'users/sessions#active',               via: :get
    match 'timeout'           => 'users/sessions#timeout',              via: :get
  end
``` 
***
You're done! Enjoy watching your sessions automatically timeout.

## Additional Configuration

By default, the JavaScript code checks the server every 60 seconds for
active sessions. If you prefer that it check more frequently, pass a
frequency attribute to the helper method. The frequency is given in
seconds. The following example checks the server every 15 seconds:

    <html>
      <head>...</head>
      <body>
        <% if current_user %>
          <%= auto_session_warning_tag %>
          <%= auto_session_timeout_js frequency: 15 %>
        <% end %>
        ...
      </body>
    </html>

Be sure to also add `<%= auto_session_warning_tag %>`.
   
### auto_session_timeout_js config options
**frequency:** how frequently browser interactive with server to find the session details,

**timeout:** auto session time out in seconds. If you set auto_session_timeout: 2.minutes on application_controller, you should set 120 seconds here.

**start:** starting time of server interaction. If it is 60, first server interaction will start after 60 seconds,

**warning:** Show warning message before session timed out. If it is 20, dialog warning message will popup before 20 seconds of timeout.

*Default values here:*
timeout: 60,
frequecy: 60,
start: 60,
warning: 20

### auto_session_warning_tag config options
**continue_button: (string)** Text for the default continue button.

**warning_title: (string)** Title of the warning modal.

**warning_message: (string)** Message that is display in the body of the warning modal.

**warning_modal_classes: (string, each class separated by a space, ex: `'btn btn-secondary'`)** CSS classes applied to the entire warning modal.

**continue_button_classes: (string, each class separated by a space, ex: `'btn btn-secondary'`)** CSS classes applied to the default warning modal footer button.

**warning_modal_footer: (string)** HTML displayed inside the warning modal footer.

**expired_message: (string)** Message that is display in the body of the expired modal.

**expired_title: (string)** Title of the expired modal.

**expired_modal_classes: (string, each class separated by a space, ex: `'btn btn-secondary'`)** CSS classes applied to the entire expired modal.

**expired_button: (string)** Text for the default expired button.

**expired_button_classes: (string, each class separated by a space, ex: `'btn btn-secondary'`)** CSS classes applied to the default expired modal footer link.

**expired_modal_footer: (string)** HTML displayed inside the warning modal footer.

*Default values here:*
```ruby
#logout warning modal
continue_button = "Continue"
warning_message = "You are about to be logged out due to inactivity.<br/><br/>Please click &lsquo;#{continue_button}&rsquo; to stay logged in."
warning_modal_classes = ''
warning_title = "Logout Warning"
continue_button_classes = 'btn'
warning_modal_footer = "<button type='button' class='#{continue_button_classes}' id='session-refresh-button' data-dismiss='modal'>#{continue_button}</button>"
    
# expired modal
expired_message = "Your session has expired.<br/><br/>Please log in again to continue."
expired_title = "Session Expired"
expired_modal_classes = ''
expired_button = "Log in"
expired_button_classes =  'btn'
expired_modal_footer ="<a class='#{expired_button_classes}' href='/timeout'>#{expired_button}</a>"
````

## TODO

* current_user must be defined
* using Prototype vs. jQuery
* setting timeout in controller vs. user

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Resources

* Repository: http://github.com/pelargir/auto-session-timeout/
* Blog: http://www.matthewbass.com
* Author: Matthew Bass
