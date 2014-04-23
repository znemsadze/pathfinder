var views=require('../views');

exports.home=function(request){
  var homeView=views.main.home(request);
  return homeView;
};
