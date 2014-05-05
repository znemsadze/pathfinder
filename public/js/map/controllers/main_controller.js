var views=require('../views')
  , points=require('./points_controller')
  ;

exports.home=function(request){
  var model;
  var delegate={
    onNewPoint:function(){
      request.displayPage(points.new_point);
    },
  };
  var homeView=views.main.home(model,delegate);
  return homeView;
};
