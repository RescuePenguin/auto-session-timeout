module AutoSessionTimeoutHelper
  def auto_session_timeout_js(options={})
    frequency = options[:frequency] || 60
    verbosity = options[:verbosity] || 2
    timeout = options[:timeout] || 60
    start = options[:start] || 60
    warning = options[:warning] || 20
    attributes = options[:attributes] || {}
    submit_form_before_logout = options[:submit_form_before_logout] || false
    form_name = options[:form_name] || ''
    submit_form_url = options[:url]
    code = <<JS

if(typeof(jQuery) != 'undefined'){
    $('#session-refresh-button').click(function() {
      $.ajax({
        type: "GET",
        url: "/application/session_time",
        dataType: "html"
      });
    });
  };
function PeriodicalQuery() {
  $.ajax({
      url: '/active',
      success: function(data) {
        if(new Date(data.timeout).getTime() < (new Date().getTime() + #{warning} * 1000)){
          $('#logout_dialog').modal({keyboard: false, backdrop: 'static'});
          if (#{submit_form_before_logout}) {
            $('form[name="' + "#{form_name}" +'"]').on('submit', function(e) {
              e.preventDefault();
              $.ajax({
                type: "PATCH",
                data: this.serialize(),
                url: "#{submit_form_url}",
                dataType: "json"
              });
            });
            $('form[name="' + "#{form_name}" +'"]').submit();
          }
        }
        if(data.live == false){
          $('#logout_dialog').modal('hide');

          $('#session_expired').modal({keyboard: false, backdrop: 'static'});
        }
      }
    });
  setTimeout(PeriodicalQuery, (#{frequency} * 1000));
}
setTimeout(PeriodicalQuery, (#{start} * 1000));
JS
    javascript_tag(code, attributes)
  end

  # Generates viewport-covering dialog HTML with message in center
  #   options={} are output to HTML. Be CAREFUL about XSS/CSRF!
  def auto_session_warning_tag(options={})
    # continue session
    continue_button = options[:continue_button] || 'Continue'
    default_warning_message = "You are about to be logged out due to inactivity.<br/><br/>Please click &lsquo;#{continue_button}&rsquo; to stay logged in."
    warning_message = options[:warning_message] || default_warning_message
    warning_modal_classes = !!(options[:warning_modal_classes]) ? options[:warning_modal_classes] : ''
    warning_title = options[:warning_title] || 'Logout Warning'
    continue_button_classes = !!(options[:continue_button_classes]) ? options[:continue_button_classes] : 'btn'
    warning_modal_footer = options[:extra_warning_option_buttons] || "<button type='button' class='#{continue_button_classes}' id='session-refresh-button' data-dismiss='modal'>#{continue_button}</button>"

    # session has expired
    default_expired_message = 'Your session has expired.<br/><br/>Please log in again to continue.'
    expired_message = options[:expired_message] || default_expired_message
    expired_title = options[:expired_title] || "Session Expired"
    expired_modal_classes = !!(options[:expired_modal_classes]) ? options[:expired_modal_classes] : ''
    expired_button = options[:expired_button] || "Log in"
    expired_button_classes = !!(options[:expired_button_classes]) ? options[:expired_button_classes] : 'btn'
    expired_modal_footer = options[:extra_expired_option_buttons] || "<a class='#{expired_button_classes}' href='/timeout'>#{expired_button}</a>"

    # save form progress before logging out
    default_submit_form_before_logout_message = 'Your session has expired but your progress has been saved.<br/><br/>Please log in again to continue.'
    submit_form_before_logout = options[:submit_form_before_logout]
    submit_form_before_logout_message = options[:submit_form_before_logout_message] || default_submit_form_before_logout_message


    # Marked .html_safe -- Passed strings are output directly to HTML!
    normal_expired_modal = "
    <div class='modal' id='session_expired' tabindex='-1' role='dialog' aria-labelledby='session_expired_label' aria-hidden='true'>
      <div class='modal-dialog  #{expired_modal_classes}' role='document'>
        <div class='modal-content'>
          <div class='modal-header'>
            <h3 class='modal-title' id='session_expired'>#{expired_title}</h3>
          </div>
          <div class='modal-body'>
            <p>#{expired_message}</p>
          </div>
          <div class='modal-footer'>
            #{expired_modal_footer}
          </div>
        </div>
      </div>
  </div>
  "

    submit_form_before_logout_modal = "
    <div class='modal' id='session_expired' tabindex='-1' role='dialog' aria-labelledby='session_expired_label' aria-hidden='true'>
      <div class='modal-dialog  #{expired_modal_classes}' role='document'>
        <div class='modal-content'>
          <div class='modal-header'>
            <h3 class='modal-title' id='session_expired'>#{expired_title}</h3>
          </div>
          <div class='modal-body'>
            <p>#{submit_form_before_logout_message}</p>
          </div>
          <div class='modal-footer'>
            #{expired_modal_footer}
          </div>
        </div>
      </div>
  </div>
  "

    "<div class='modal' id='logout_dialog' tabindex='-1' role='dialog' aria-labelledby='logout_dialog_label' aria-hidden='true'>
  <div class='modal-dialog #{warning_modal_classes}' role='document'>
    <div class='modal-content'>
      <div class='modal-header'>
        <h3 class='modal-title' id='logout_dialog'>#{warning_title}</h3>
      </div>
      <div class='modal-body'>
        <p>#{warning_message}</p>
      </div>
      <div class='modal-footer'>
        #{warning_modal_footer}
      </div>
    </div>
  </div>
</div>
  #{submit_form_before_logout ? submit_form_before_logout_modal : normal_expired_modal}
    ".html_safe
  end

end

ActionView::Base.send :include, AutoSessionTimeoutHelper
