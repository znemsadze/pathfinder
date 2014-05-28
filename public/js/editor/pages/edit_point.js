var ui=require('../ui')
  , forms=require('./forms')
  , api=require('../api')
  , geo=require('./geo')
  ;

var self, canEdit
  , map, marker
  , layout, formLayout, uiInitialized=false
  , titleElement=ui.html.pageTitle('შეცვლა')
  ;

module.exports=function(){
  return {
    onEnter: function(){
      self=this;

      if (!uiInitialized){ initUI(self); }

      // map=self.map;
      // initMap();

      // resetLayout();
      // canEdit=true;
      // getForm().loadModel(getId());

      return layout;
    },
    onExit: function() {
      geo.resetMap(map);
    },
  };
};

var initUI=function(){
  var saveAction=function(){
    // TODO:
  };

  var cancelAction=function(){
    // TODO: remove marker
    // path.setMap(null);
    // var feature=getFeature();
    // if(feature){ map.data.add(feature); }
    self.openPage('root');
  };

  var form1=forms.point.form({save_action:saveAction, cancel_action:cancelAction});
  formLayout=ui.layout.card({children: [form1]});

  layout=ui.layout.vertical({children:[titleElement,formLayout]});
  uiInitialized=true;
};

var getFeature=function(){ return self.params.feature; }
var isNewMode=function(){ return !getFeature(); };
var getForm=function(){ return  formLayout.selected(); };

var getType=function(){
  var feature=getFeature();
  if(feature){
    return geo.getType(feature);
  } else{
    return self.params.type;
  }
};

var getId=function(){
  var feature=getFeature();
  return feature&&feature.getId();
};
