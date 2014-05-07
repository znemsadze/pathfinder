var ui=require('../ui')
  , api=require('../api')
  , geo=require('./geo')
  ;

var map
  , layout
  , uiInitialized=false
  , titleElement=ui.html.pageTitle('გზის შეცვლა')
  , notLocked
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;
      notLocked=true;

      if (!uiInitialized){ initUI(self); }

      //map=self.map;
      //initMap();
      //resetPathInfo();

      return layout;
    },
    onExit: function() {
      selectedFeatures=[];
      geo.resetMap(map);
    },
  };
};

var initUI=function(self){
  layout=ui.layout.vertical({
    children: [
      titleElement,
    ]
  });

  uiInitialized=true;
};
