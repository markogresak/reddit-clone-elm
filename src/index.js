'use strict';

// var storedState = localStorage.getItem('elm-todo-save');
// var startingState = storedState ? JSON.parse(storedState) : null;
// var todomvc = Elm.Todo.fullscreen(startingState);
// todomvc.ports.setStorage.subscribe(function(state) {
//     localStorage.setItem('elm-todo-save', JSON.stringify(state));
// });

var Elm = require('./Main.elm');
var mountNode = document.getElementById('root');

// The third value on embed are the initial values for incomming ports into Elm
var app = Elm.Main.embed(mountNode);
