/**
 * converts polyline into array of points
 */
exports.pointsFromPath=function(path){
  var points=[];
  path.forEach(function(element,index){
    points.push({
      lat:element.lat(),
      lng:element.lng(),
    });
  });
  return points;
};

/**
 * add model error
 */
exports.addError=function(model,field,message){
  if(!field){ field='_toplevel'; } // toplevel error
  if(!model.errors){ model.errors={}; }
  if(!model.errors[field]){ model.errors[field]=[]; }
  model.errors[field].push(message);
};

/**
 * clear model errors
 */
exports.clearErrors=function(model){
  model.errors={};
};