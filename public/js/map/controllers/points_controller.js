var views=require('../views');

exports.new_point=function(request){
  var model;
  var delegate;
  var newPointView=views.points.new_point(model,delegate);
  return newPointView;
};
