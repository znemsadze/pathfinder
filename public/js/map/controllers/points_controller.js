var views=require('../views');

exports.new_point=function(request){
  var newPointView=views.points.new_point();
  return newPointView;
};