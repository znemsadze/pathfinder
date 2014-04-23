var views=require('../views');

exports.home=function(request){
  var model=null;
  var homeView=views.main.home(model);
  return homeView;
};
