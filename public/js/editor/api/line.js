var utils=require('./utils')
  ;

var BASE_PATH='/api/lines';

var save=function(id,model,callback){
  utils.clearErrors(model);

  var path=model.path
    , name=model.name
    , description=model.description
    ;

  if(path.getLength()>1){
    var points=utils.pointsFromPath(path);
    var params={id:id, points:points, name:name, description:description};
    $.post(BASE_PATH+'/edit',params,function(data){
      if(callback){ callback(null,data); }
    }).fail(function(err){
      if(callback){ callback(err,null); }
    });
    return true;
  }
  return false;
};

exports.newLine=function(model,callback){ return save(null,model,callback); };
exports.editLine=function(id,model,callback){ return save(id,model,callback); };

exports.deleteLine=function(id,callback){
  $.post(BASE_PATH+'/delete',{id:id},function(data){
    if(callback){ callback(null,data); }
  }).fail(function(err){
    if(callback){ callback(err,null); }
  });
  return true;
};