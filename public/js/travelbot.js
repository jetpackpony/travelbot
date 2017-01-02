var scheme   = "ws://";
var uri      = scheme + window.document.location.host + "/";
var ws       = new WebSocket(uri);
ws.onmessage = function(message) {
  $("#chat-body").append(message.data + "<br>");
};

$("#input-form").on("submit", function(event) {
  event.preventDefault();
  var text = $("#input-text")[0].value;
  ws.send(text);
  $('#chat-body').append("-------" + text + "<br>");
  $("#input-text")[0].value = "";
});
