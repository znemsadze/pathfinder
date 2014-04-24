var forma=require('../../forma')
  , html=require('../../forma/html');

module.exports=function(model,delegate){
  initUI();
  return mLayout;
};

var mLayout
  , mTitle
  , mDescription
  ;

var initUI=function(){
  mTitle=forma.pageTitle('ახალი წერტილი');
  mDescription=html.p('ახალი წერტილის კოორდინატის მისაღებად დააწკაპეთ რუკაზე',{class:'text-muted'});

var txt1=forma.textField('name',{label:'დასახელება'});

  mLayout=forma.verticalLayout([mTitle,mDescription,txt1]);
};
