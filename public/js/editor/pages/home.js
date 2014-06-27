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
  , pathInfo=ui.html.el('div',{style: 'margin: 16px 0;'})
  , selectedFeature
  , secondaryToolbar=ui.button.toolbar([])
  , btnHome, btnSearch
  , btnNewPath, btnNewLine, btnNewTower, btnNewOffice, btnNewSubstation // new objects
  , btnDelete, btnEdit, btnAddToPath
  , confirmTitle=ui.html.p('საჭიროა დასტური',{class: 'page-header', style: 'font-weight:bold; font-size: 1.2em;'})
  , confirmText=ui.html.p('დაადასტურეთ, რომ ნამდვილად გინდათ მონიშნული ობიექტის წაშლა?',{class: 'text-danger'})
  , toolbar2=ui.button.toolbar([])
  , pathPoints=[]
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
  // main toolbar actions
  btnHome=ui.button.actionButton('', function(){ window.location='/'; }, {icon:'home'});
  btnSearch=ui.button.actionButton('ძებნა', function(){ self.openPage('search'); }, {icon: 'search'});

  btnNewPath=ui.button.actionLink('მარშუტი', function(){
    if(!locked){ self.openPage('edit_path',{type:geo.TYPE_PATH}); }
  });
  btnNewLine=ui.button.actionLink('გადამცემი ხაზი', function(){
    if(!locked){ self.openPage('edit_path',{type:geo.TYPE_LINE}); }
  });
  btnNewTower=ui.button.actionLink('ანძა', function(){
    if(!locked){ self.openPage('edit_point',{type:geo.TYPE_TOWER}); }
  });
  btnNewOffice=ui.button.actionLink('ოფისი', function(){
    if(!locked){ self.openPage('edit_point',{type:geo.TYPE_OFFICE}); }
  });
  btnNewSubstation=ui.button.actionLink('ქვესადგური', function(){
    if(!locked){ self.openPage('edit_point',{type:geo.TYPE_SUBSTATION}); }
  });

  var buttons=[btnNewPath,btnNewLine,{divider:true},btnNewOffice,btnNewSubstation,btnNewTower];
  var newObjects=ui.button.dropdown('ახალი ობიექტი',buttons, {type:'success'});  

  toolbar.addButton(btnSearch);
  toolbar.addButton(btnHome);
  toolbar.addButton(newObjects);

  // secondary actions

  btnDelete=ui.button.actionButton('წაშლა', function(){
    if(!locked){ openPage(CONFIRM); }
  }, {icon: 'trash-o', type: 'danger'});

  btnEdit=ui.button.actionButton('შეცვლა', function(){
    if(!locked){
      if(geo.isPath(selectedFeature)||geo.isLine(selectedFeature)){
        self.openPage('edit_path',{feature: selectedFeature});
      } else if(geo.isTower(selectedFeature)||geo.isOffice(selectedFeature)||geo.isSubstation(selectedFeature)){
        self.openPage('edit_point',{feature: selectedFeature});
      }
    }
  }, {icon: 'pencil', type: 'warning'});

  btnAddToPath=ui.button.actionButton('დანიშნულების წერტილი', function(){
    if(pathPoints.indexOf(selectedFeature) == -1){
      pathPoints.push(selectedFeature);
      resetPathInfo();
      if(pathPoints.length > 1) { getShortestPath(); }
    }
  }, {icon: 'plus', type: 'success'});

  // page1 layout

  var titleElement=ui.html.pageTitle('საწყისი');
  page1=ui.layout.vertical({
    children: [
      titleElement,
      toolbar,
      featureInfo,
      secondaryToolbar,
      pathInfo,
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
    if(geo.isPointlike(selectedFeature)){
      secondaryToolbar.addButton(btnAddToPath);
    }
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
  else if(geo.isOffice(selectedFeature)){ locked=api.office.deleteOffice(id,callback); }
  else if(geo.isSubstation(selectedFeature)){ locked=api.substation.deleteSubstation(id,callback); }
};

var resetPathInfo=function(){
  pathInfo.innerText='';
  if(pathPoints.length>0){
    var titleEleemnt=ui.html.el('h4', {class: 'page-header'}, 'გზის პარამეტრები (' + pathPoints.length + ')');
    pathInfo.appendChild(titleEleemnt);
    var totalLength = 0;
    for(var i=0,l=pathPoints.length; i<l; i++){
      var f=pathPoints[i];
      if(f){
        var tbar=ui.html.el('div',{class:'pull-right'});
        var btnDelete=ui.html.el('button',{class:['btn','btn-xs','btn-danger'], 'data-id':f.getId()});
        btnDelete.innerHTML='<i class="fa fa-trash-o"></i>';
        btnDelete.onclick=deletePathPoint;
        tbar.appendChild(btnDelete);
        pathInfo.appendChild(tbar);

        var d1=ui.html.el('div',{class:'search-result','data-id':f.getId()});
        d1.innerHTML=geo.featureShortDescritpion(map,f);
        pathInfo.appendChild(d1);
        if(pathPoints.length > 1 && paths[i]){
          var d2 = ui.html.el('div', {style: 'padding: 5px; background: #FFFFDD'});
          var length = paths[i].length;
          totalLength += length;
          d2.innerHTML='მონაკვეთი <strong>' + (i+1) + '</strong>: <code>' + length.toFixed(3) + '</code> კმ';
          pathInfo.appendChild(d2);
        }
      }
    }
    if(pathPoints.length > 1){
      var summary=ui.html.el('div', {style: 'padding: 5px; background: #DDFFDD'});
      summary.innerHTML='<strong>მანძილი სულ</strong>: <code>' + totalLength.toFixed(3) + '</code> კმ';
      pathInfo.appendChild(summary);
    }
  }
};

var paths=[];

var clearPaths=function(){
  for(var i=0,l=paths.length; i < l; i++){
    var path = paths[i];
    path.getPath().clear();
    path.setMap(null);
  }
  paths=[];
};

var getShortestPath=function() {
  clearPaths();
  if(pathPoints.length > 1) {
    api.shortestpath.getShortestPath(pathPoints, function(err, data){
      if(data) {
        for(var i=0,l=data.length;i<l;i++){
          var points=data[i].points;
          var path = new google.maps.Polyline({ geodesic: true, strokeColor: '#00AA00', strokeOpacity: 0.75, strokeWeight: 10 });
          path.length=data[i].length;
          for(var j=0, k=points.length; j < k; j++){
            var point=points[j];
            path.getPath().push(new google.maps.LatLng(point.lat, point.lng));
          }
          path.setMap(map);
          paths.push(path);
        }
        resetPathInfo();
      } else if(err) {
        console.log(err);
      }
    });
  }
};

var deletePathPoint=function() {
  var id=this.getAttribute('data-id');
  var indexToRemove=pathPoints.map(function(x){ return x.getId() }).indexOf(id);
  console.log(indexToRemove);
  pathPoints.splice(indexToRemove,1);
  resetPathInfo();
  getShortestPath();
};