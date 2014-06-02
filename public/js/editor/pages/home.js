var ui=require('../ui')
  , api=require('../api')
  , geo=require('./geo')
  ;

var MAIN=0    // main page
  , CONFIRM=1 // confirm page
  ;

var map
  , uiInitialized=false, locked
  , layout, page1, page2, toolbar=ui.button.toolbar([])
  , featureInfo=ui.html.p('',{style:'margin:16px 0;'})
  , selectedFeature
  , secondaryToolbar=ui.button.toolbar([])
  , btnNewPath, btnNewLine, btnNewTower // new objects
  , btnDelete, btnEdit // change objects
  , confirmTitle=ui.html.p('საჭიროა დასტური',{class: 'page-header', style: 'font-weight:bold; font-size: 1.2em;'})
  , confirmText=ui.html.p('დაადასტურეთ, რომ ნამდვილად გინდათ მონიშნული ობიექტის წაშლა?',{class: 'text-danger'})
  , toolbar2=ui.button.toolbar([])
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;
      locked=false;

      if (!uiInitialized){
        initUI(self);
        layout=ui.layout.card({children: [page1,page2]});
      }

      map=self.map;
      initMap();
      resetFeatureInfo();

      openPage(MAIN);

      if(self.params&&self.params.selectedFeature){
        changeSelection(self.params.selectedFeature);
      }

      return layout;
    },
    onExit: function() {
      if(selectedFeature){ changeSelection(selectedFeature); }
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
  btnNewPath=ui.button.actionLink('მარშუტი', function(){
    if(!locked){ self.openPage('edit_path',{type:geo.TYPE_PATH}); }
  });
  btnNewLine=ui.button.actionLink('გადამცემი ხაზი', function(){
    if(!locked){ self.openPage('edit_path',{type:geo.TYPE_LINE}); }
  });

  var newObjects=ui.button.dropdown('ახალი ობიექტი',[btnNewPath,btnNewLine], {type:'success'});  

  btnDelete=ui.button.actionButton('წაშლა', function(){
    if(!locked){ openPage(CONFIRM); }
  }, {icon: 'trash-o', type: 'danger'});

  btnEdit=ui.button.actionButton('შეცვლა', function(){
    if(!locked){
      if(geo.isPath(selectedFeature)||geo.isLine(selectedFeature)){
        self.openPage('edit_path',{feature: selectedFeature});
      } else if(geo.isTower(selectedFeature)){
        self.openPage('edit_point',{feature: selectedFeature});
      }
    }
  }, {icon: 'pencil', type: 'warning'});

  toolbar.addButton(newObjects);

  var titleElement=ui.html.pageTitle('საწყისი');
  page1=ui.layout.vertical({
    children: [
      titleElement,
      toolbar,
      featureInfo,
      secondaryToolbar,
    ]
  });
};

var initPage2=function(self){
  var btnCancel=ui.button.actionButton('გაუქმება', function(){ openPage(MAIN); });
  var btnConfirm=ui.button.actionButton('ვადასტურებ', deleteSelectedFeature, {icon:'warning', type: 'danger'});

  toolbar2.addButton(btnConfirm);
  toolbar2.addButton(btnCancel);

  var titleElement=ui.html.pageTitle('საწყისი');
  page2=ui.layout.vertical({
    children: [
      titleElement,
      confirmTitle,
      confirmText,
      toolbar2
    ]
  });
};

var openPage=function(idx){ layout.showAt(idx); };

var resetFeatureInfo=function(){
  secondaryToolbar.clearButtons();
  if(!selectedFeature){
    featureInfo.setHtml('მონიშნეთ ობიექტი რუკაზე მასზე ინფორმაციის მისაღებად.');
  } else{
    featureInfo.setHtml(geo.featureDescription(map,selectedFeature));
    secondaryToolbar.addButton(btnEdit);
    secondaryToolbar.addButton(btnDelete);
  }
  openPage(MAIN);
};

var initMap=function(){
  map.data.addListener('mouseover', function(evt) {
    var f=evt.feature;
    f.hovered=true;
    map.data.revertStyle(f);
  });
  map.data.addListener('mouseout', function(evt) {
    var f=evt.feature;
    f.hovered=false;
    map.data.revertStyle(f);
  });
  map.data.addListener('click', function(evt){
    changeSelection(evt.feature);
  });
};

var changeSelection=function(f){
  if(f==selectedFeature){
    f.selected=false;
    selectedFeature=null;
  } else {
    if(selectedFeature){
      selectedFeature.selected=false;
      map.data.revertStyle(selectedFeature);
    }
    selectedFeature=f;
    f.selected=true;
  }
  map.data.revertStyle(f);
  resetFeatureInfo();
};

var deleteSelectedFeature=function(){
  if(!selectedFeature){ return; }

  var id=selectedFeature.getId();

  var callback=function(){
    map.data.remove(selectedFeature);
    selectedFeature=null;
    resetFeatureInfo();
    locked=false;
  };

  if(geo.isPath(selectedFeature)){ locked=api.path.deletePath(id,callback); }
  else if(geo.isLine(selectedFeature)){ locked=api.line.deleteLine(id,callback); }
  else if(geo.isTower(selectedFeature)){ locked=api.tower.deleteTower(id,callback); }
};
