// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

/* kamiliff default behavior */
window.addEventListener("liff_ready", function(event){
  register_kamiliff_submit();
});

window.addEventListener("liff_submit", function(event){
  var json = JSON.stringify(event.detail.data);
  var url = event.detail.url;
  var method = event.detail.method;
  var request_text = method + " " + url + "\n" + json;
  liff_send_text_message(request_text);
});