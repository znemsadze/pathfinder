exports.resetMap=function(map){
  google.maps.event.clearInstanceListeners(map);
  google.maps.event.clearInstanceListeners(map.data);
  map.data.revertStyle();
};

exports.copyFeatureToPath=function(feature,path){
  var g=feature.getGeometry();
  var ary=g.getArray();
  path.getPath().clear();
  for(var i=0,l=ary.length;i<l;i++){
    var p=ary[i];
    var point=new google.maps.LatLng(p.lat(),p.lng());
    path.getPath().push(point);
  }
};

exports.closestFeaturePoint=function(feature,point){
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