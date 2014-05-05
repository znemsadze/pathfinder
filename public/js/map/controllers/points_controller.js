var views=require('../views')
  , models=require('../models')
  ;

exports.new_point=function(request){
  var map=request.map;
  var marker=new google.maps.Marker();
  var point=models.point.create();

  var updateMarkerPosition=function(position){
    marker.setMap(map);
    marker.setPosition(position);
  };

  map.setOptions({draggableCursor:'crosshair'});
  google.maps.event.addListener(map,'click',function(evt) {
    var newPosition=evt.latLng;
    updateMarkerPosition(newPosition);
    point.update_attributes({lat:newPosition.lat(), lng:newPosition.lng()});
    newPointView.updateLocation({lat:newPosition.lat(), lng:newPosition.lng()});
  });

  var newPointView=views.points.new_point({point:point});
  return newPointView;
};