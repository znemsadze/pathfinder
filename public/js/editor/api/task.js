var utils=require('./utils')
  ;

var BASE_PATH='/api/tasks';

var save=function(model,callback){
  utils.clearErrors(model);

  var note=model.note
    , assignee_id=model.assignee_id
    , destinations=model.destinations
    , paths=model.paths
    ;

  if(!assignee_id){
    utils.addError(model,'region_id','აარჩიეთ შემსრულებელი');
    return false;
  }

  var params = { assignee_id: assignee_id, note: note, paths: paths, destinations: destinations };
  var url = BASE_PATH + '/new';
  $.post(url, params, function(data){ callback(null,data); }).fail(function(err){ callback(err,null); });

  return true;
};

exports.save=save;