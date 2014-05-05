var BASE_PATH='/api/geo';

var pointsFromPath=function(path){
  var points=[];
  path.forEach(function(element,index){
    points.push({
      id:element.id,
      lat:element.lat(),
      lng:element.lng(),
      featureId:element.featureId
    });
  });
  return points;
};

exports.newPath=function(path,callback){
  if(path.getLength()>1){
    var points=pointsFromPath(path);
    $.post(BASE_PATH+'/new_path',{points:points},function(data) {
      callback(data);
    });
    return true;
  }
  return false;
};

exports.editPath=function(id,path,callback){
  if(path.getLength()>1){
    var points=pointsFromPath(path);
    $.post(BASE_PATH+'/edit_path',{id:id,points:points},function(data) {
      callback(data);
    });
    return true;
  }
  return false;
};