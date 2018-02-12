'use strict';

var USER_TOKEN_KEY_NAME = 'USER_TOKEN';

var Elm = require('./Main.elm');
var app = Elm.Main.fullscreen(localStorage[USER_TOKEN_KEY_NAME] || null);

app.ports.storeSession.subscribe(function(sessionUser) {
  console.log('storeSession', sessionUser);
  localStorage[USER_TOKEN_KEY_NAME] = sessionUser;
});

window.addEventListener("storage", function(event) {
  console.log('storage', event);
  if (event.storageArea === localStorage && event.key === USER_TOKEN_KEY_NAME) {
    app.ports.onSessionChange.send(event.newValue);
  }
}, false);
