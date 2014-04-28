var BASE_PATH='/api/geo';

exports.savePath=function(path,callback){
  if(path.getLength()>1) {
    var points=[];
    path.forEach(function(element,index){
      points.push({lat:element.lat(),lng:element.lng(),featureId:element.featureId});
    });
    $.post('/api/geo/new_path',{id:path.id,points:points},function(data) {
      callback(data);
    });
  }
};