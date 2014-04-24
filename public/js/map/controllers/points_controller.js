var views=require('../views')
  , models=require('../models')
  ;

exports.new_point=function(request){
  var map=request.map;
  var marker;
  var point=models.point.create();

  var showmarker=function(position){
    if(!marker){ marker=new google.maps.Marker({position:position,map:map}); }
    else{ marker.setPosition(position); }
  };

  map.setOptions({draggableCursor:'crosshair'});
  google.maps.event.addListener(map,'click',function(evt) {
    var position=evt.latLng;

    showmarker(position);

    newPointView.updateLocation({lat:position.lat(), lng:position.lng()});
  });

  var newPointView=views.points.new_point({point:point});
  return newPointView;
};