var ui=require('../ui')
  , api=require('../api')
  , geo=require('./geo')
  ;

var map
  , uiInitialized=false
  , layout
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;

      if (!uiInitialized){
        // initUI(self);
        layout=ui.layout.vertical();
      }

      map=self.map;

      return layout;
    },
    onExit: function() {
      geo.resetMap(map);
    },
  };
};