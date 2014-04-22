(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
// var forma=require('./forma');
var html=require('./html');

// google map object
var map;

var initializeGoogleMap=function(opts){
  return function(){
    var centerLat=opts.centerLat||41.693328079546774;
    var centerLng=opts.centerLat||44.801473617553710;
    var centerPoint=new google.maps.LatLng(centerLat,centerLng);

    var startZoom=opts.startZoom||10;

    var mapOptions = {
      zoom: startZoom,
      center: centerPoint,
      mapTypeId: google.maps.MapTypeId.TERRAIN
    };

    map = new google.maps.Map(document.getElementById(opts.mapid), mapOptions);
  };
};

var loadGoogleMapScript=function(opts){
  var host='https://maps.googleapis.com/maps/api/js';
  var script = document.createElement('script');
  script.type = 'text/javascript';
  script.src = host+'?v=3.ex&key='+opts.apikey+'&sensor=false&callback=initializeGoogleMap';
  document.body.appendChild(script);
};

module.exports=function(opts){
  window.onload = loadGoogleMapScript(opts);
  window.initializeGoogleMap=initializeGoogleMap(opts);
};
},{"./html":2}],2:[function(require,module,exports){

},{}],3:[function(require,module,exports){
require('./googlemap')({
  mapid:'map',
  sidebarid:'sidebar',
  apikey:'AIzaSyA-SMUKodB-2pDhnk_c35AEBoNFwsE03Ok',
});
},{"./googlemap":1}]},{},[3])