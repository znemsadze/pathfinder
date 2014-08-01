var ui=require('../ui')
  , api=require('../api')
  , geo=require('./geo')
  ;

var MAIN=0    // main page
  , CONFIRM=1 // confirm page
  ;

var map, editMode
  , uiInitialized=false, locked
  , layout, page1, page2, toolbar=ui.button.toolbar([])
  , featureInfo=ui.html.p('',{style:'margin:16px 0;'})
  , pathInfo=ui.html.el('div',{style: 'margin: 16px 0;'})
  , selectedFeature
  , secondaryToolbar=ui.button.toolbar([]), pathToolbar=ui.button.toolbar([]), taskToolbar=ui.button.toolbar([])
  , btnHome, btnSearch
  , btnNewPath, btnNewLine, btnNewTower, btnNewOffice, btnNewSubstation // new objects
  , btnDelete, btnEdit, btnAddToPath, btnNewTask, btnShortestPath
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
      editMode = self.editMode;

      if (!uiInitialized){
        initUI(self);
        layout=ui.layout.card({children: [page1,page2]});
      }

      map=self.map;
      initMap();
      resetPathInfo();

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
  if(editMode){ toolbar.addButton(newObjects); }

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

  btnAddToPath=ui.button.actionButton('წერტილის დამატება', function(){
    if (pathPoints.indexOf(selectedFeature) == -1) {
      pathPoints.push(selectedFeature);
      clearPaths();
      resetPathInfo();
      // if (pathPoints.length > 1) { getShortestPath(); }
    }
  }, {icon: 'plus'});

  btnShortestPath = ui.button.actionButton('გზის აგება', function() {
    if (pathPoints.length > 1 && !pathCalculationInProgress) {
      getShortestPath();
    }
  }, { icon: 'road' });

  btnNewTask=ui.button.actionButton('დავალების შექმნა', function() {
    // if(paths.length > 0) {
      self.openPage('task', {destinations: pathPoints, paths: paths});
    // }
  }, {icon: 'tasks', type: 'success'})

  // page1 layout

  var tabs = ui.html.el('div', {style: 'margin-top: 16px;'});
  tabs.innerHTML = ['<ul class="nav nav-tabs" role="tablist">',
    '<li class="active"><a href="#feature" role="tab" data-toggle="tab">ობიექტი</a></li>',
    '<li><a href="#path" role="tab" data-toggle="tab">დავალება</a></li>',
    '</ul>',
  ].join('');
  var tabContent = ui.html.el('div', {class: 'tab-content'});
  var t1 = ui.html.el(tabContent, 'div', {class: ['tab-pane','active'], id: 'feature'});
  t1.appendChild(featureInfo);
  t1.appendChild(secondaryToolbar);
  var t2 = ui.html.el(tabContent, 'div', {class: ['tab-pane'], id: 'path'});
  pathToolbar.style.marginTop="16px";
  t2.appendChild(taskToolbar);
  taskToolbar.style.marginBottom = taskToolbar.style.marginTop = '8px';
  t2.appendChild(pathInfo);
  t2.appendChild(pathToolbar);
  tabs.appendChild(tabContent);
 
  page1=ui.layout.vertical({ children: [ toolbar, tabs, ] });
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

var resetFeatureInfo = function(){
  secondaryToolbar.clearButtons();
  pathToolbar.clearButtons();

  taskToolbar.appendChild(btnNewTask);

  if (!selectedFeature) {
    featureInfo.setHtml('მონიშნეთ ობიექტი რუკაზე მასზე ინფორმაციის მისაღებად.');
  } else{
    featureInfo.setHtml(geo.featureDescription(map,selectedFeature) + geo.featureImages(selectedFeature));
    if(editMode) {
      secondaryToolbar.addButton(btnEdit);
      secondaryToolbar.addButton(btnDelete);
    }
    if(geo.isPointlike(selectedFeature) && !pathCalculationInProgress){
      pathToolbar.addButton(btnAddToPath);
    }
    if(!pathCalculationInProgress && pathPoints.length > 1) {
      pathToolbar.addButton(btnShortestPath);
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

var changeSelection=function(f) {
  if (f === selectedFeature) {
    f.selected = false;
    selectedFeature = null;
  } else {
    if (selectedFeature) {
      selectedFeature.selected = false;
      map.data.revertStyle(selectedFeature);
    }
    selectedFeature = f;
    f.selected = true;
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
  if(pathPoints.length > 0) {
    var titleEleemnt=ui.html.el('h4', {class: 'page-header'}, 'გზის პარამეტრები (' + pathPoints.length + ')');
    pathInfo.appendChild(titleEleemnt);
    var totalLength = 0;
    for(var i=0,l=pathPoints.length; i<l; i++){
      var f=pathPoints[i];
      if(f){
        // toolbar

        var tbar=ui.html.el('div',{class:['pull-right','btn-group']});
        pathInfo.appendChild(tbar);
        // move up action
        if(!pathCalculationInProgress) {
          if (i > 0) {
            var btnUp=ui.html.el('button',{class:['btn','btn-xs','btn-default'], 'data-id':f.getId()});
            btnUp.innerHTML='<i class="fa fa-arrow-up"></i>';
            btnUp.onclick=movePathPointUp;
            tbar.appendChild(btnUp);
          }
        }
        // move down action
        if(!pathCalculationInProgress) {
          if (i != pathPoints.length-1) {
            var btnDown=ui.html.el('button',{class:['btn','btn-xs','btn-default'], 'data-id':f.getId()});
            btnDown.innerHTML='<i class="fa fa-arrow-down"></i>';
            btnDown.onclick=movePathPointDown;
            tbar.appendChild(btnDown);
          }
        }
        // delete action
        if(!pathCalculationInProgress) {
          var btnDelete=ui.html.el('button',{class:['btn','btn-xs','btn-danger'], 'data-id':f.getId()});
          btnDelete.innerHTML='<i class="fa fa-trash-o"></i>';
          btnDelete.onclick=deletePathPoint;
          tbar.appendChild(btnDelete);
        }

        // content

        var d1=ui.html.el('div',{class:'search-result','data-id':f.getId()});
        d1.innerHTML=geo.featureShortDescritpion(map,f);
        d1.onclick=pathPointSelected;
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

    // footer: summary
    if (pathCalculationInProgress) {
      var waiting = ui.html.el('div', {style: 'padding: 5px; background: #FFDDDD'});
      waiting.innerHTML = '<i class="fa fa-circle-o-notch fa-spin"></i> გთხოვთ დაელოდოთ...';
      pathInfo.appendChild(waiting);
    } else if(pathPoints.length > 1 && paths.length > 0){
      var summary=ui.html.el('div', {style: 'padding: 5px; background: #DDFFDD'});
      summary.innerHTML='<strong>მანძილი სულ</strong>: <code>' + totalLength.toFixed(3) + '</code> კმ';
      pathInfo.appendChild(summary);
    }
  } else {
    pathInfo.innerHTML = '<p class="text-muted">არც ერთი დანიშნულების წერიტილი არაა დამატებული.</p>';
  }

  resetFeatureInfo();
};

var paths=[];
var pathCalculationInProgress = false;

var clearPaths=function() {
  for(var i = 0, l = paths.length; i < l; i++) {
    var path = paths[i];
    path.getPath().clear();
    path.setMap(null);
  }
  paths = [];
};

var getShortestPath=function() {
  clearPaths();
  if(pathPoints.length > 1) {
    // show wait
    pathCalculationInProgress = true;
    resetPathInfo();

    api.shortestpath.getShortestPath(pathPoints, function(err, data) {
      if(data && typeof data === 'object') {
        for(var i=0, l=data.length; i < l; i++) {
          var points=data[i].points;
          var path = new google.maps.Polyline({ geodesic: true, strokeColor: '#00FF00', strokeOpacity: 0.75, strokeWeight: 10 });
          path.length=data[i].length;
          for(var j=0, k=points.length; j < k; j++){
            var point=points[j];
            path.getPath().push(new google.maps.LatLng(point.lat, point.lng));
          }
          path.setMap(map);
          paths.push(path);
        }
      } else if(err) {
        console.log(err);
      }
      pathCalculationInProgress = false;
      resetPathInfo();
    });
  }
};

var deletePathPoint=function() {
  var id=this.getAttribute('data-id');
  var indexToRemove=pathPoints.map(function(x){ return x.getId() }).indexOf(id);
  pathPoints.splice(indexToRemove,1);
  clearPaths();
  resetPathInfo();
};

var movePathPointUp=function(){ movePathPoint(this.getAttribute('data-id'), true); };
var movePathPointDown=function(){ movePathPoint(this.getAttribute('data-id'), false); };

var movePathPoint=function(id, up){
  var index=pathPoints.map(function(x){ return x.getId() }).indexOf(id);
  if(up && index==0){ return; }
  if(!up && index==pathPoints.length-1){ return; }
  if(up){
    var e1=pathPoints[index];
    var e2=pathPoints[index-1];
    pathPoints.splice(index-1,2,e1,e2);
  } else {
    var e1=pathPoints[index];
    var e2=pathPoints[index+1];
    pathPoints.splice(index,2,e2,e1)
  }
  resetPathInfo();
  getShortestPath();
};

var pathPointSelected=function(){
  var f=map.data.getFeatureById(this.getAttribute('data-id'));
  changeSelection(f);
};