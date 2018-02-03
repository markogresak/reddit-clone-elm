'use strict';

// Require index.html so it gets copied to dist
require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('root');

// The third value on embed are the initial values for incomming ports into Elm
var app = Elm.Main.embed(mountNode);
