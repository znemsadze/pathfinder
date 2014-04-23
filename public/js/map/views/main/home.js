var forma=require('../../forma');

module.exports=function(){
  initUI();
  return layout;
};

var layout
  , title
  , toolbar
  , btnNewPoint
  ;

var initUI=function(){
  title=forma.pageTitle('საწყისი');

  btnNewPoint=forma.actionButton([forma.faIcon('plus'),' ახალი წერტილი'], function(){ alert('ახალი წერტილია დასამატებელი!'); });
  toolbar=forma.toolbar([btnNewPoint]);

  layout=forma.verticalLayout([title,toolbar]);
};