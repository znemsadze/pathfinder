var ui=require('../ui')
  , geo=require('./geo')
  ;

var map
  , layout
  , uiInitialized=false
  , titleElement=ui.html.pageTitle('საწყისი')
  , toolbar=ui.button.toolbar([])
  , selectedFeatures=[]
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;

      if (!uiInitialized){ initUI(self); }

      map=self.map;
      initMap();

      return layout;
    },
    onExit: function() {
      selectedFeatures=[];
      geo.resetMap(map);
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

var isSelected=function(f){
  return selectedFeatures.indexOf(f) !== -1;
};

var addSelection=function(f){
  map.data.overrideStyle(f,{strokeWeight:5,strokeColor:'#00AA00'});
  selectedFeatures.push(f);
};

var removeSelection=function(f){
  var idx=selectedFeatures.indexOf(f);
  selectedFeatures.splice(idx,1);
  map.data.revertStyle(f);
};

var initMap=function(){
  map.data.addListener('mouseover', function(evt) {
    if(!isSelected(evt.feature)){
      map.data.overrideStyle(evt.feature,{strokeWeight:10,strokeColor:'#00FF00'});
    }
  });
  map.data.addListener('mouseout', function(evt) {
    if(!isSelected(evt.feature)){
      map.data.revertStyle(evt.feature);
    }
  });
  map.data.addListener('click', function(evt){
    var f=evt.feature;
    if(isSelected(f)){ removeSelection(f); }
    else{ addSelection(f); }
  });
};