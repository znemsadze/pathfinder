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

exports.newPath=function(model,callback){
  var path=model.path;
  if(path.getLength()>1){
    var points=pointsFromPath(path);
    var params={points:points, type_id:model.type_id, surface_id:model.surface_id, detail_id:model.detail_id};
    $.post(BASE_PATH+'/new_path',params,function(data){
      if(callback){ callback(data); }
    }).fail(function(err){
      if(callback){ callback(err); }
    });
    return true;
  }
  return false;
};

exports.editPath=function(id,path,callback){
  if(path.getLength()>1){
    var points=pointsFromPath(path);
    $.post(BASE_PATH+'/edit_path',{id:id,points:points},function(data){
      if(callback){ callback(data); }
    }).fail(function(err){
      if(callback){ callback(err); }
    });
    return true;
  }
  return false;
};

exports.deletePath=function(id,callback){
  $.post(BASE_PATH+'/delete_path',{id:id},function(data){
    if(callback){ callback(data); }
  }).fail(function(err){
    if(callback){ callback(err); }
  });;
  return true;
};