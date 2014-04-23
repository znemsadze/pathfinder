var forma=require('../../forma');

module.exports=function(model){
  initUI();
  return mLayout;
};

var mLayout
  , mTitle
  ;

var initUI=function(){
  mTitle=forma.pageTitle('ახალი წერტილი');

  mLayout=forma.verticalLayout([mTitle,]);
};