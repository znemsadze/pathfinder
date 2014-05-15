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

var addError=function(model,field,message){
  if(!field){ field='_toplevel'; }
  if(!model.errors){ model.errors={}; }
  if(!model.errors[field]){ model.errors[field]=[]; }
  model.errors[field].push(message);
};

exports.newPath=function(model,callback){
  var path=model.path
    , detail_id=model.detail_id
    , description=model.description
    ;

  if(path.getLength()>1){
    if(!detail_id){
      addError(model,'detail_id','აარჩიეთ საფარის დეტალი');
      return false;
    }
    var points=pointsFromPath(path);
    var params={points:points, detail_id:detail_id, description:description};
    $.post(BASE_PATH+'/new_path',params,function(data){
      if(callback){ callback(data); }
    }).fail(function(err){
      if(callback){ callback(err); }
    });
    return true;
  }
  return false;
};

exports.editPath=function(id,model,callback){
  var path=model.path
    , detail_id=model.detail_id
    , description=model.description
    ;

  if(path.getLength()>1){
    if(!detail_id){
      addError(model,'detail_id','აარჩიეთ საფარის დეტალი');
      return false;
    }
    var points=pointsFromPath(path);
    $.post(BASE_PATH+'/edit_path',{id:id, points:points, detail_id:detail_id, description:description},function(data){
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