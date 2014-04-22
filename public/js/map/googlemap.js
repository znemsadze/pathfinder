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