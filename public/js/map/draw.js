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

exports.drawPath=function(map){
  var path = new google.maps.Polyline({
    map:map,
    geodesic:true,
    strokeColor:'#FF0000',
    strokeOpacity:1.0,
    strokeWeight:1,
    editable:true,
  });
  var paused=false
    , id=undefined
    ;

  google.maps.event.addListener(map, 'click', function(evt){
    if(!paused){ path.getPath().push(evt.latLng); }
  });

  google.maps.event.addListener(path, 'dblclick', function(evt){
    if(!paused){
      if(typeof evt.vertex==='number'){
        path.getPath().removeAt(evt.vertex,1);
      }}
  });

  map.data.addListener('mouseover', function(evt) {
    map.data.overrideStyle(evt.feature,{strokeWeight:10,strokeColor:'green'});
  });
  map.data.addListener('mouseout', function(evt) {
    map.data.revertStyle();
  });
  map.data.addListener('dblclick', function(evt) {
    var f=evt.feature;
    id=f.getId();
    copyFeatureToPath(f,path);
    map.data.remove(f);
  });

  return {
    getPath: function(){ var p=path.getPath(); p.id=id; return p; },
    restartEdit: function(){ path.getPath().clear(); id=undefined; },
    setPaused: function(val){ paused=val; },
    endEdit: function() {
      resetMap(map);
      path.setMap(null);
    },
  };
};