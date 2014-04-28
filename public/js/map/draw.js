var resetMap=function(map){
  google.maps.event.clearInstanceListeners(map);
};

// map.data.addListener('mouseover', function(evt) {
//   map.data.overrideStyle(evt.feature,{strokeWeight:10});
// });
// map.data.addListener('mouseout', function(evt) {
//   map.data.revertStyle();
// });

exports.drawPath=function(map){
  var path = new google.maps.Polyline({
    map:map,
    geodesic:true,
    strokeColor:'#FF0000',
    strokeOpacity:1.0,
    strokeWeight:1,
    editable:true,
  });
  var paused=false;

  google.maps.event.addListener(map, 'click', function(evt){
    if(!paused){ path.getPath().push(evt.latLng); }
  });

  google.maps.event.addListener(path, 'dblclick', function(evt){
    if(!paused){
      if(typeof evt.vertex==='number'){
        path.getPath().removeAt(evt.vertex,1);
      }}
  });

  return {
    getPath: function(){ return path.getPath(); },
    restartEdit: function(){ path.getPath().clear(); },
    setPaused: function(val){ paused=val; },
    endEdit: function() {
      resetMap(map);
      path.setMap(null);
    },
  };
};