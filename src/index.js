'use strict';

var USER_TOKEN_KEY_NAME = 'USER_TOKEN';
var rememberMeKey = 'rememberMe'

function getBoolKey(json, key) {
  try {
    var obj = typeof json === 'string' ? JSON.parse(json) : json;
    return Boolean(obj[key]);
  } catch (e) {
    return false;
  }
}

var storage = getBoolKey(localStorage[USER_TOKEN_KEY_NAME], rememberMeKey) ? localStorage : sessionStorage;

var Elm = require('./Main.elm');
var app = Elm.Main.fullscreen(storage[USER_TOKEN_KEY_NAME] || null);

app.ports.storeSession.subscribe(function(sessionData) {
  if (sessionData === null) {
    storage.removeItem(USER_TOKEN_KEY_NAME);
  } else {
    storage = getBoolKey(sessionData, rememberMeKey) ? localStorage : sessionStorage;
    storage[USER_TOKEN_KEY_NAME] = sessionData;
  }
});

app.ports.confirm.subscribe(function(msg) {
  app.ports.onConfirm.send(confirm(msg));
});

window.addEventListener("storage", function(e) {
  if ((e.storageArea === localStorage || e.storageArea === sessionStorage) && e.key === USER_TOKEN_KEY_NAME) {
    app.ports.onSessionChange.send(e.newValue);
  }
}, false);
