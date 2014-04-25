(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var draw=require('./draw');

var mapElement;
var sidebarElement;
var apikey;
var defaultCenterLat;
var defaultCenterLng;
var defaultZoom;
var map;

/**
 * This function is used to start the application.
 */
exports.start=function(opts){
  sidebarElement=document.getElementById((opts&&opts.sidebarid)||'sidebar');
  mapElement=document.getElementById((opts&&opts.mapid)||'map');
  defaultCenterLat=(opts&&opts.centerLat)||41.693328079546774;
  defaultCenterLng=(opts&&opts.centerLat)||44.801473617553710;
  defaultZoom=(opts&&opts.startZoom)||10;
  window.onload=loadingGoogleMapsAsyncronously;
};

var loadingGoogleMapsAsyncronously=function(){
  var host='https://maps.googleapis.com/maps/api/js';
  var script = document.createElement('script');
  script.type = 'text/javascript';
  if (apikey){ script.src = host+'?v=3.ex&key='+apikey+'&sensor=false&callback=onGoogleMapLoaded'; }
  else{ script.src = host+'?v=3.ex&sensor=false&callback=onGoogleMapLoaded'; }
  document.body.appendChild(script);
  window.onGoogleMapLoaded=onGoogleMapLoaded;
};

var onGoogleMapLoaded=function(){
  initMap();
};

var initMap=function(){
  var mapOptions = {
    zoom: defaultZoom,
    center: new google.maps.LatLng(defaultCenterLat,defaultCenterLng),
    mapTypeId: google.maps.MapTypeId.TERRAIN
  };
  map=new google.maps.Map(mapElement, mapOptions);

  // map.data.loadGeoJson('/test.json?v=1');
  // map.data.setStyle({
  //   strokeColor:'red',
  //   strokeOpacity:0.5,
  // });
  // map.data.addListener('mouseover', function(evt) {
  //   map.data.overrideStyle(evt.feature,{strokeWeight:10});
  // });
  // map.data.addListener('mouseout', function(evt) {
  //   map.data.revertStyle();
  // });

  // draw path
  draw.drawPath(map);
};
},{"./draw":2}],2:[function(require,module,exports){
exports.drawPath=function(map){
  var path = new google.maps.Polyline({
    map:map,
    geodesic:true,
    strokeColor:'#FF0000',
    strokeOpacity:1.0,
    strokeWeight:1,
    editable:true,
  });

  google.maps.event.addListener(map, 'click', function(evt){
    path.getPath().push(evt.latLng);
  });

  google.maps.event.addListener(path, 'dblclick', function(evt){
    if(typeof evt.vertex==='number'){
      path.getPath().removeAt(evt.vertex,1);
    }
  });
};
},{}],3:[function(require,module,exports){
var app=require('./app');

app.start();
},{"./app":1}]},{},[3])