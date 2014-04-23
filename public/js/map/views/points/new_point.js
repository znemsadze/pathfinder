var forma=require('../../forma');

module.exports=function(model){
  initUI();
  return layout;
};

var layout
  , title
  , toolbar
  ;

var initUI=function(){
  title=forma.pageTitle('ახალი წერტილი');

  // btnNewPoint=forma.actionButton([forma.faIcon('plus'),' ახალი წერტილი'], function(){ alert('ახალი წერტილია დასამატებელი!'); });
  // toolbar=forma.toolbar([btnNewPoint]);

  // layout=forma.verticalLayout([title,toolbar]);
  layout=forma.verticalLayout([title]);
};