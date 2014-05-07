var ui=require('../ui')
  ;

var layout
  , uiInitialized=false
  , titleElement=ui.html.pageTitle('ახალი გზის დამატება')
  , toolbar=ui.button.toolbar([])
  , desriptionElement=ui.html.p('ახალი გზის გასავლებად გამოიყენეთ თქვენი მაუსი. რედაქტირების დასრულების შემდეგ დააჭირეთ შენახვის ღილაკს.',{style:'margin-top:8px;'})
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;

      if(!uiInitialized){ initUI(self); }

      return layout;
    },
  };
};

var initUI=function(self){
  var btnBack=ui.button.actionButton('უკან', function(){
    self.openPage('root');
  }, {icon:'arrow-left'});

  toolbar.addButton(btnBack);

  layout=ui.layout.vertical({
    children: [
      titleElement,
      toolbar,
      desriptionElement,
    ]
  });

  uiInitialized=true;
};