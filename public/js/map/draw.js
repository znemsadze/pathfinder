var resetMap=function(map){
  google.maps.event.clearInstanceListeners(map);
};

var copyFeatureToPath=function(feature,path){
  var g=feature.getGeometry();
  var ary=g.getArray();
  path.getPath().clear();    
  for(var i=0,l=ary.length;i<l;i++){
    var p=ary[i];
    var point=new google.maps.LatLng(p.lat(),p.lng());
    path.getPath().push(point);
  }
};

var closestPointTo=function(feature,point){
  var minDistance
    , minPoint
    ;
  var g=feature.getGeometry();
  var ary=g.getArray();
  for(var i=0,l=ary.length;i<l;i++){
    var p=ary[i];
    var x=new google.maps.LatLng(p.lat(),p.lng());
    var distance=google.maps.geometry.spherical.computeDistanceBetween(p,point);
    if(!minDistance || distance<minDistance){
      minDistance=distance;
      minPoint=p;
    }
  }
  return minPoint;
};

exports.drawPath=function(map){
  var path=new google.maps.Polyline({
    map:map,
    geodesic:true,
    strokeColor:'#FF0000',
    strokeOpacity:1.0,
    strokeWeight:1,
    editable:true,
  });
  var paused=false
    , featureId=undefined
    ;
  var featureCircle=new google.maps.Circle({
    strokeColor: '#FF0000',
    strokeOpacity: 0.8,
    strokeWeight: 1,
    fillColor: '#FF0000',
    fillOpacity: 0.35,
    radius: 50,
  });

  google.maps.event.addListener(map, 'click', function(evt){
    if(!paused){ path.getPath().push(evt.latLng); }
  });

  google.maps.event.addListener(path, 'dblclick', function(evt){
    if(!paused){
      if(typeof evt.vertex==='number'){
        path.getPath().removeAt(evt.vertex,1);
      }}
  });

  map.data.addListener('click', function(evt) {
    if(!paused){
      var closestPoint=closestPointTo(evt.feature,evt.latLng);
      closestPoint.featureId=evt.feature.getId();
      path.getPath().push(closestPoint);
    }
  });

  map.data.addListener('mouseover', function(evt) {
    map.data.overrideStyle(evt.feature,{strokeWeight:10,strokeColor:'green'});
    featureCircle.setMap(map);
  });

  map.data.addListener('mouseout', function(evt) {
    map.data.revertStyle();
    featureCircle.setMap(null);
  });

  map.data.addListener('mousemove', function(evt){
    featureCircle.setCenter(closestPointTo(evt.feature,evt.latLng));
  });

  map.data.addListener('dblclick', function(evt) {
    var f=evt.feature;
    featureId=f.getId();
    copyFeatureToPath(f,path);
    map.data.remove(f);
    evt.stop();
  });

  return {
    getPath: function(){ var p=path.getPath(); p.id=featureId; return p; },
    restartEdit: function(){ path.getPath().clear(); featureId=undefined; },
    setPaused: function(val){ paused=val; },
    endEdit: function() {
      resetMap(map);
      path.setMap(null);
    },
  };
};