var draw=require('./draw')
  , ui=require('./ui')
  , api=require('./api')
  ;

var mapElement;
var sidebarElement;
var toolbarElement;
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
  toolbarElement=document.getElementById((opts&&opts.toolbarid)||'toolbar');
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
  var baseUrl=host+'?v=3.ex&sensor=false&callback=onGoogleMapLoaded&libraries=geometry';
  if (apikey){ script.src = baseUrl+'&key='+apikey; }
  else{ script.src = baseUrl; }
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

  loadData(map);

  var pauseEditing=function() {
    btnSavePath.setWaiting(true);
    drawHandle.setPaused(true);
  };

  var resumeEditing=function(data){
    btnSavePath.setWaiting(false);
    drawHandle.setPaused(false);
    drawHandle.restartEdit();
  };

  var btnSavePath=ui.button.actionButton('გზის შენახვა', function(){
    var path=drawHandle.getPath()
      , id=path.id
      , resp
      ;
    pauseEditing();
    if(id){
      resp=api.editPath(id,path,function(data){
        loadData(map,data.id);
        //console.log(data);
        resumeEditing();
      });
    } else {
      resp=api.newPath(path, function(data){
        loadData(map,data.id);
        resumeEditing();
      });
    }
    if(!resp){ resumeEditing(); }
  }, {type: 'success'});
  var btnDeletePath=ui.button.actionButton('გზის წაშლა',function(){
    var path=drawHandle.getPath(), id=path.id;
    if (id){
      resp=api.deletePath(id,function(data){
        drawHandle.restartEdit();
      });
    }
  }, {type: 'danger'});
  var btcCancelEdit=ui.button.actionButton('გაუქმება', function(){
    drawHandle.cancelEdit();
  });

  toolbarElement.appendChild(btnSavePath);
  toolbarElement.appendChild(btnDeletePath);
  toolbarElement.appendChild(btcCancelEdit);

  // draw path
  var drawHandle=draw.drawPath(map);
};

var loadData=function(map,id){
  var url=id? '/geo/map.json?id='+id:'/geo/map.json'
  // console.log(url);
  map.data.loadGeoJson(url);
  map.data.setStyle({
    strokeColor:'red',
    strokeWeight:1,
    strokeOpacity:0.5,
  });
};