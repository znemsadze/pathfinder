var BASE_PATH='/api/shortestpath';

exports.getShortestPath=function(features,callback){
  var ids=features.map(function(x){ return x.getProperty('class') +"/" + x.getId(); });

  $.get(BASE_PATH, {ids: ids}, function(data) {

    callback(null, data);

  }).fail(function(err){

    callback(err, null);

  });
};
