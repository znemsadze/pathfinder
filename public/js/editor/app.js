var ui=require('./ui')
  , api=require('./api')
  , router=require('./router')
  , pages=require('./pages')
  , geo=require('./pages/geo')
  ;

var mapElement, sidebarElement, toolbarElement
  , defaultCenterLat, defaultCenterLng, defaultZoom
  , apikey, map
  , app
  ;

/**
 * Entry point for the application.
 */
exports.start=function(opts){
  sidebarElement=document.getElementById((opts&&opts.sidebarid)||'sidebar');
  toolbarElement=document.getElementById((opts&&opts.toolbarid)||'toolbar');
  mapElement=document.getElementById((opts&&opts.mapid)||'map');
  defaultCenterLat=(opts&&opts.centerLat)||42.3;
  defaultCenterLng=(opts&&opts.centerLat)||43.8;
  defaultZoom=(opts&&opts.startZoom)||7;
  window.onload=loadingGoogleMapsAsyncronously;
};

var loadingGoogleMapsAsyncronously=function(){
  var host='https://maps.googleapis.com/maps/api/js';
  var script = document.createElement('script');
  script.type = 'text/javascript';
  var baseUrl=host+'?v=3.ex&sensor=false&callback=onGoogleMapLoaded&libraries=geometry';
  if (apikey){ script.src = baseUrl+'&key='+apikey; }
  else{ script.src = baseUrl; }
  document.body.appendChild(script);
  window.onGoogleMapLoaded=onGoogleMapLoaded;
};

var onGoogleMapLoaded=function(){
  initMap();
  initRouter();
};

var initMap=function(){
  var mapOptions = {
    zoom: defaultZoom,
    center: new google.maps.LatLng(defaultCenterLat,defaultCenterLng),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  map=new google.maps.Map(mapElement, mapOptions);

  map.loadData=function(opts){
    var url='/api/objects.json?';
    var query=[];
    if(typeof opts==='object'){
      if(opts.id){ query.push('id='+opts.id); }
      if(opts.type){ query.push('type='+opts.type); }
    }
    map.data.loadGeoJson(url+query.join('&'));
  };

  map.data.setStyle(function(f) {
    var name=f.getProperty('name')
      , isSelected=f.selected
      , isHovered=f.hovered
      ;
    if (geo.isLine(f)){
      var strokeColor, strokeWeight;
      if(isSelected){ strokeColor='#00AA00'; strokeWeight=5; }
      else if(isHovered){ strokeColor='#00FF00'; strokeWeight=10; }
      else{ strokeColor='#FF0000'; strokeWeight=1; }
      return {
        strokeColor: strokeColor,
        strokeWeight: strokeWeight,
        strokeOpacity: 0.5,
        title: name,
      };
    } else if (geo.isPath(f)) {
      var strokeColor, strokeWeight;
      if(isSelected){ strokeColor='#00AAAA'; strokeWeight=5; }
      else if(isHovered){ strokeColor='#00FFFF'; strokeWeight=10; }
      else{ strokeColor='#0000FF'; strokeWeight=2; }
      return {
        strokeColor: strokeColor,
        strokeWeight: strokeWeight,
        strokeOpacity: 0.5,
        title: name,
      };
    } else if (geo.isTower(f)){
      var icon;
      if(isSelected){ icon='/map/tower_selected.png'; }
      else if(isHovered){ icon='/map/tower_hovered.png'; }
      else{ icon='/map/tower.png'; }
      return {
        icon: icon,
        visible: true,
        clickable: true,
        title: name,
      };
    }
  });

  map.loadData();

  window.map=map;
};

// router

var initRouter=function(){
  app=router.initApplication({map:map,toolbar:toolbarElement,sidebar:sidebarElement});

  app.addPage('root', pages.home());
  app.addPage('edit_path', pages.edit_path());
  app.addPage('edit_point', pages.edit_point());

  app.openPage('root');
};
