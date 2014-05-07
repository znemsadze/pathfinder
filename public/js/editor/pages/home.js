var ui=require('../ui')
  , geo=require('./geo')
  ;

var map
  , layout
  , uiInitialized=false
  , titleElement=ui.html.pageTitle('საწყისი')
  , toolbar=ui.button.toolbar([])
  , pathToolbar=ui.button.toolbar([])
  , pathInfo=ui.html.p('',{style:'margin:8px 0;'})
  , selectedFeatures=[]
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;

      if (!uiInitialized){ initUI(self); }

      map=self.map;
      initMap();
      resetPathInfo();

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
      pathInfo,
      pathToolbar,
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
  resetPathInfo();
};

var removeSelection=function(f){
  var idx=selectedFeatures.indexOf(f);
  selectedFeatures.splice(idx,1);
  map.data.revertStyle(f);
  resetPathInfo();
};

var resetPathInfo=function(){
  var size=selectedFeatures.length;
  if(size===0){
    pathInfo.setHtml('მონიშნეთ გზა მასზე ინფორმაციის მისაღებად.');
  } else if (size===1){
    pathInfo.setHtml('მონიშნული გზის სიგძრეა: <code>'+geo.calcFeatureDistance(map,selectedFeatures).toFixed(3)+'</code> კმ');
  } else {
    pathInfo.setHtml('მონიშნულია '+size+' გზა, საერთო სიგრძით: <code>'+geo.calcFeatureDistance(map,selectedFeatures).toFixed(3)+'</code> კმ');
  }
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