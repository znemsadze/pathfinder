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