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
  var paused=false
    , currentFeature=undefined
    , path=new google.maps.Polyline({
        map:map,
        geodesic:true,
        strokeColor:'#0000FF',
        strokeOpacity:1.0,
        strokeWeight:1,
        editable:true,
      })
    , marker = new google.maps.Marker({
        icon: {
          path: google.maps.SymbolPath.CIRCLE,
          fillOpacity: 0,
          strokeOpacity: 1,
          strokeColor: '#FF0000',
          strokeWeight: 1,
          scale: 5, //pixels
        }
      })
    ;

  google.maps.event.addListener(map, 'click', function(evt){
    if(!paused){
      path.getPath().push(evt.latLng);
    }
  });

  google.maps.event.addListener(path, 'dblclick', function(evt){
    if(!paused){
      if(typeof evt.vertex==='number'){
        path.getPath().removeAt(evt.vertex,1);
      }
    }
  });

  map.data.addListener('click', function(evt) {
    if(!paused){
      var closestPoint=closestPointTo(evt.feature,evt.latLng);
      path.getPath().push(closestPoint);
    }
  });

  map.data.addListener('mouseover', function(evt) {
    map.data.overrideStyle(evt.feature,{strokeWeight:10,strokeColor:'green'});
    marker.setMap(map);
  });

  map.data.addListener('mouseout', function(evt) {
    map.data.revertStyle();
    marker.setMap(null);
  });

  map.data.addListener('mousemove', function(evt){
    marker.setPosition(closestPointTo(evt.feature,evt.latLng));
  });

  map.data.addListener('dblclick', function(evt) {
    if (currentFeature){
      map.data.add(currentFeature);
    }
    currentFeature=evt.feature;
    copyFeatureToPath(currentFeature,path);
    map.data.remove(currentFeature);
    evt.stop();
  });

  return {
    getPath: function(){
      var p=path.getPath();
      if(currentFeature){
        p.id=currentFeature.getId();
      }
      return p;
    },
    restartEdit: function(){
      path.getPath().clear();
      currentFeature=undefined;
    },
    setPaused: function(val){
      paused=val;
    },
    cancelEdit: function(){
      if (currentFeature){
        map.data.add(currentFeature);
      }
      this.restartEdit();
    },
    endEdit: function() {
      resetMap(map);
      path.setMap(null);
    },
  };
};