var views=require('../views');

exports.home=function(opts){
  var homeView=views.main.home();
  return homeView;
};
