var forma=require('../forma');

// var b1=forma.actionLink([forma.faIcon('heart'),' Button1'], function(){ alert('Button1 clicked!'); });
// var b2=forma.actionLink(['Button2'], function(){ alert('Button2 clicked!'); });
// var b3=forma.actionButton('Button3', function(){ alert('Button3 clicked!'); });
// var dd=forma.dropdown(forma.faIcon('plus'),[b1,b2], {size:'small'});
// var gr=forma.buttonGroup([dd,b3]);
// var tb=forma.toolbar([gr]);
// sidebarElement.appendChild(tb);

module.exports=function(opts){
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