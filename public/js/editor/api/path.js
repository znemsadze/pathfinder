var utils=require('./utils')
  ;

var BASE_PATH='/api/paths';

exports.newPath=function(model,callback){
  utils.clearErrors(model);

  var path=model.path
    , detail_id=model.detail_id
    , description=model.description
    ;

  if(path.getLength()>1){
    if(!detail_id){
      utils.addError(model,'detail_id','აარჩიეთ საფარის დეტალი');
      return false;
    }
    var points=utils.pointsFromPath(path);
    var params={points:points, detail_id:detail_id, description:description};
    $.post(BASE_PATH+'/new',params,function(data){
      if(callback){ callback(data); }
    }).fail(function(err){
      if(callback){ callback(err); }
    });
    return true;
  }
  return false;
};

exports.editPath=function(id,model,callback){
  utils.clearErrors(model);

  var path=model.path
    , detail_id=model.detail_id
    , description=model.description
    ;

  if(path.getLength()>1){
    if(!detail_id){
      utils.addError(model,'detail_id','აარჩიეთ საფარის დეტალი');
      return false;
    }
    var points=utils.pointsFromPath(path);
    $.post(BASE_PATH+'/edit',{id:id, points:points, detail_id:detail_id, description:description},function(data){
      if(callback){ callback(data); }
    }).fail(function(err){
      if(callback){ callback(err); }
    });
    return true;
  }
  return false;
};

exports.deletePath=function(id,callback){
  $.post(BASE_PATH+'/delete',{id:id},function(data){
    if(callback){ callback(data); }
  }).fail(function(err){
    if(callback){ callback(err); }
  });;
  return true;
};