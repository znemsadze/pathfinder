var ui=require('../ui')
  , api=require('../api')
  , geo=require('./geo')
  ;

var MAIN=0    // main page
  , CONFIRM=1 // confirm page
  ;

var map
  , layout
  , page1
  , page2
  , uiInitialized=false
  , titleElement=ui.html.pageTitle('საწყისი')
  , toolbar=ui.button.toolbar([])
  , pathInfo=ui.html.p('',{style:'margin:8px 0;'})
  , selectedFeatures=[]
  , pathToolbar=ui.button.toolbar([])
  , btnDeletePath
  , btnEditPath
  , notLocked
  , confirmTitle=ui.html.p('საჭიროა დასტური',{class: 'page-header', style: 'font-weight:bold; font-size: 1.2em;'})
  , confirmText=ui.html.p('დაადასტურეთ, რომ ნამდვილად გინდათ მონიშნული გზ(ებ)ის წაშლა?',{class: 'text-danger'})
  , toolbar2=ui.button.toolbar([])
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;
      notLocked=true;

      if (!uiInitialized){
        initUI(self);
        layout=ui.layout.card({children: [page1,page2]});
      }

      map=self.map;
      initMap();
      resetPathInfo();

      openPage(MAIN);

      return layout;
    },
    onExit: function() {
      selectedFeatures=[];
      geo.resetMap(map);
    },
  };
};

var initUI=function(self){
  initPage1(self);
  initPage2(self);
  uiInitialized=true;
};


var initPage1=function(self){
  var btnNewPath=ui.button.actionButton('ახალი გზა', function(){
    if(notLocked){
      self.openPage('new_path');
    }
  }, {icon:'plus'});

  btnDeletePath=ui.button.actionButton('წაშლა', function(){
    if(notLocked){
      openPage(CONFIRM);
    }
  }, {icon: 'trash-o', type: 'danger'});

  btnEditPath=ui.button.actionButton('შეცვლა', function(){
    if(notLocked){
      self.openPage('edit_path', {feature: selectedFeatures[0]});
    }
  }, {icon: 'pencil', type: 'warning'});

  toolbar.addButton(btnNewPath);

  page1=ui.layout.vertical({
    children: [
      titleElement,
      toolbar,
      pathInfo,
      pathToolbar,
    ]
  });
};

var initPage2=function(self){
  var btnCancel=ui.button.actionButton('გაუქმება', function(){
    openPage(MAIN);
  });

  var btnConfirm=ui.button.actionButton('ვადასტურებ', function(){
    var ids=selectedFeatures.map(function(x){return x.getId();}).join(',');
    notLocked=!api.deletePath(ids,function(){
      for(var i=0,l=selectedFeatures.length;i<l;i++){
        map.data.remove(selectedFeatures[i]);
      }
      selectedFeatures=[];
      resetPathInfo();
      notLocked=true;
    });
  },{icon:'warning', type: 'danger'});

  toolbar2.addButton(btnConfirm);
  toolbar2.addButton(btnCancel);

  page2=ui.layout.vertical({
    children: [
      confirmTitle,
      confirmText,
      toolbar2
    ]
  });
};

var openPage=function(idx){
  layout.showAt(idx);
};

var isSelected=function(f){
  return selectedFeatures.indexOf(f)!==-1;
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
  pathToolbar.clearButtons();
  var size=selectedFeatures.length;
  if(size===0){
    pathInfo.setHtml('მონიშნეთ გზა მასზე ინფორმაციის მისაღებად.');
  } else if (size===1){
    pathInfo.setHtml('მონიშნული გზის სიგძრეა: <code>'+geo.calcFeatureDistance(map,selectedFeatures).toFixed(3)+'</code> კმ');
    pathToolbar.addButton(btnEditPath);
    pathToolbar.addButton(btnDeletePath);
  } else {
    pathInfo.setHtml('მონიშნულია <strong>'+size+'</strong> გზა, საერთო სიგრძით: <code>'+geo.calcFeatureDistance(map,selectedFeatures).toFixed(3)+'</code> კმ');
    pathToolbar.addButton(btnDeletePath);
  }
  openPage(MAIN);
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
