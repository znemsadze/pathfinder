var forma=require('../../forma')
  , html=require('../../forma/html');

module.exports=function(){
  initUI();
  return mLayout;
};

var mLayout
  , mTitle
  , mDescription
  ;

var initUI=function(){
  mTitle=forma.pageTitle('ახალი წერტილი');
  mDescription=html.p('ახალი წერტილის კოორდინატების მისაღებად დააწკაპეთ რუკაზე',{class:'text-muted'});
  mLayout=forma.verticalLayout([mTitle,mDescription]);
};
