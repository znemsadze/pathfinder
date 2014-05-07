var ui=require('../ui')
  ;

var layout
  , uiInitialized=false
  , titleElement=ui.html.pageTitle('საწყისი')
  , toolbar=ui.button.toolbar([])
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;

      if (!uiInitialized){
        initUI(self);
      }

      return layout;
    },
  };
};

var initUI=function(self){
  var btnNewPath=ui.button.actionButton('ახალი გზა', function(){
    self.openPage('new_path');
  }, {icon:'plus'});

  toolbar.addButton(btnNewPath);

  layout=ui.layout.vertical({
    children: [
      titleElement,
      toolbar,
    ]
  });

  uiInitialized=true;
};