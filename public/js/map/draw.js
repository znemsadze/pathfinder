var poly=[];

exports.polylinedraw=function(map){
  google.maps.event.addListener(map, 'click', function() {
    console.log('clicked');
  });
};