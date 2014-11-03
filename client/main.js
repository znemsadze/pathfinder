var googlemaps = require('./googlemaps');
var jQuery = require('jquery');

var logger = function(message) {
  var el = document.getElementById('log-messages');
  if( message ) {
    el.innerHTML = '<span>' + message + '</span>';
  } else {
    el.innerHTML = '';
  }
};

googlemaps.start().then(googlemaps.create).then(function(map) {
  logger('იტვირთება...');
});
