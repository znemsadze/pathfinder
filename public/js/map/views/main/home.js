var forma=require('../../forma');



module.exports=function(model,delegate){
  initUI();
  return layout;
};

var layout
  , title
  , toolbar
  , btnNewPoint
  ;

var initUI=function(delegate){
  title=forma.pageTitle('საწყისი');

  btnNewPoint=forma.actionButton([forma.faIcon('plus'),' ახალი წერტილი'], delegate&&delegate.onNewPoint);
  toolbar=forma.toolbar([btnNewPoint]);

  layout=forma.verticalLayout([title,toolbar]);
};