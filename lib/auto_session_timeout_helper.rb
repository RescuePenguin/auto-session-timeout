module AutoSessionTimeoutHelper
  def auto_session_timeout_js(options={})
    frequency = options[:frequency] || 60
    verbosity = options[:verbosity] || 2
    timeout = options[:timeout] || 60
    start = options[:start] || 60
    warning = options[:warning] || 20
    attributes = options[:attributes] || {}
    code = <<JS

if(typeof(jQuery) != 'undefined'){
    $('session-refresh-button').click(function() {
        $.ajax({
          type: "GET",
          url: "/application/session_time",
          dataType: "html"
      });
    });

  });
function PeriodicalQuery() {
  $.ajax({
      url: '/active',
      success: function(data) {
        if(new Date(data.timeout).getTime() < (new Date().getTime() + #{warning} * 1000)){
          showDialog();
        }
        if(data.live == false){
          window.location.href = '/timeout';
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
    default_message = "You are about to be logged out due to inactivity.<br/><br/>Please click &lsquo;Continue&rsquo; to stay logged in."
    html_message = options[:message] || default_message
    warning_title = options[:title] || "Logout Warning"
    warning_classes = !!(options[:classes]) ? ' class="' + options[:classes] + '"' : ''

    # Marked .html_safe -- Passed strings are output directly to HTML!
    "<div class='modal fade' id='logout_dialog' tabindex='-1' role='dialog' aria-labelledby='logout_dialog_label' aria-hidden='true'>
  <div class='modal-dialog' role='document'>
    <div class='modal-content'>
      <div class='modal-header'>
        <h3 class='modal-title' id='logout_dialog'>#{warning_title}</h3>
      </div>
      <div class='modal-body #{warning_classes}'>
        <p>#{html_message}</p>
      </div>
      <div class='modal-footer'>
        <button type='button' class='usa-button-primary' id='session-refresh-button' data-dismiss='modal'>Continue</button>
      </div>
    </div>
  </div>
</div>".html_safe
  end

end

ActionView::Base.send :include, AutoSessionTimeoutHelper
