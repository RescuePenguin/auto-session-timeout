module AutoSessionTimeoutHelper
  def auto_session_timeout_js(options={})
    frequency = options[:frequency] || 60
    verbosity = options[:verbosity] || 2
    timeout = options[:timeout] || 60
    start = options[:start] || 60
    warning = options[:warning] || 20
    attributes = options[:attributes] || {}
    form_name = options[:form_name] || ''
    code = <<JS

if(typeof(jQuery) != 'undefined'){
  $('#session-refresh-button').click(function() {
    $.ajax({
      type: "GET",
      url: "/application/session_time",
      dataType: "html"
    });
  });

  $('#expired_button').click(function() {
    //do not want the saveBeforeTimeout to reset before the system has a chance to go back to the log in screen
    //this tells the application that the 'saveBeforeTimeout' item is ready to be reset when this button is clicked
    window.sessionStorage.setItem('resetSaveBeforeTimeout', '1');
  });
};

var saved_before_session_end = false;

function PeriodicalQuery() {
  $.ajax({
      url: '/active',
      success: function(data) {
        if(new Date(data.timeout).getTime() < (new Date().getTime() + #{warning} * 1000)){
          $('#logout_dialog').modal({keyboard: false, backdrop: 'static'});
        }
        if(data.live == false){
          $('#logout_dialog').modal('hide');
          $('#session_expired_dialog').modal({keyboard: false, backdrop: 'static'});
          var form = $("form[name='#{form_name}']");
          if (form.length > 0) {
              var formData = new FormData(form[0]);
              form.append('<input type="hidden" name="save_before_timeout" value="true" />');
              if (!saved_before_session_end && window.sessionStorage.getItem('saveBeforeTimeout') !== '1') {
                saved_before_session_end = true;
                $('#session_expired_dialog .saving-loader').show();
                $('#expired_button').hide();
                $.ajax({
                    url: form[0].action,
                    type: 'post',
                    dataType: 'json',
                    processData: false,
                    contentType: false,
                    data: formData
                }).done(function() {
                    //this prevents saving if the user refreshes the page on a form
                    window.sessionStorage.setItem('saveBeforeTimeout', '1');
                    $('#session_expired_dialog .saving-loader').hide();
                    $('#expired_button').show();
                });
              }
          }
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
    default_warning_message = "You are about to be logged out due to inactivity.<br/><br/>Please click &ldquo;#{continue_button}&rdquo; to stay logged in."
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
    expired_modal_footer = options[:extra_expired_option_buttons] || "<span class='saving-loader' style='display:none;'><span class='fa fa-spinner fa-pulse fa-2x fa-fw tiny-loader'></span> Saving...</span>
                                                                        <a class='#{expired_button_classes}' id='expired_button' href='/timeout'>#{expired_button}</a>"

    # Marked .html_safe -- Passed strings are output directly to HTML!
    normal_expired_modal = "
    <div class='modal' id='session_expired_dialog' tabindex='-1' role='dialog' aria-labelledby='session_expired_dialog_label' aria-hidden='true'>
      <div class='modal-dialog  #{expired_modal_classes}' role='document'>
        <div class='modal-content'>
          <div class='modal-header'>
            <h3 class='modal-title' id='session_expired_title'>#{expired_title}</h3>
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
  #{normal_expired_modal}
    ".html_safe
  end

end

ActionView::Base.send :include, AutoSessionTimeoutHelper
