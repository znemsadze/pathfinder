var views=require('../views');

exports.new_point=function(request){
  var newPointView=views.points.new_point();
  var map=request.map;
  var marker;

  var showmarker=function(position){
    if(!marker){ marker=new google.maps.Marker({position:position,map:map}); }
    else{ marker.setPosition(position); }
  };

  map.setOptions({draggableCursor:'crosshair'});
  google.maps.event.addListener(map,'click',function(evt) {
    var position=evt.latLng;
    showmarker(position);
  });

  return newPointView;
};