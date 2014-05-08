(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var BASE_PATH='/api/geo';

var pointsFromPath=function(path){
  var points=[];
  path.forEach(function(element,index){
    points.push({
      id:element.id,
      lat:element.lat(),
      lng:element.lng(),
      featureId:element.featureId
    });
  });
  return points;
};

exports.newPath=function(path,callback){
  if(path.getLength()>1){
    var points=pointsFromPath(path);
    $.post(BASE_PATH+'/new_path',{points:points},function(data){
      if(callback){ callback(data); }
    }).fail(function(err){
      if(callback){ callback(err); }
    });
    return true;
  }
  return false;
};

exports.editPath=function(id,path,callback){
  if(path.getLength()>1){
    var points=pointsFromPath(path);
    $.post(BASE_PATH+'/edit_path',{id:id,points:points},function(data){
      if(callback){ callback(data); }
    }).fail(function(err){
      if(callback){ callback(err); }
    });
    return true;
  }
  return false;
};

exports.deletePath=function(id,callback){
  $.post(BASE_PATH+'/delete_path',{id:id},function(data){
    if(callback){ callback(data); }
  }).fail(function(err){
    if(callback){ callback(err); }
  });;
  return true;
};
},{}],2:[function(require,module,exports){
var ui=require('./ui')
  , api=require('./api')
  , router=require('./router')
  , pages=require('./pages')
  ;

var mapElement, sidebarElement, toolbarElement
  , defaultCenterLat, defaultCenterLng, defaultZoom
  , apikey, map
  , app
  ;

/**
 * Entry point for the application.
 */
exports.start=function(opts){
  sidebarElement=document.getElementById((opts&&opts.sidebarid)||'sidebar');
  toolbarElement=document.getElementById((opts&&opts.toolbarid)||'toolbar');
  mapElement=document.getElementById((opts&&opts.mapid)||'map');
  defaultCenterLat=(opts&&opts.centerLat)||41.693328079546774;
  defaultCenterLng=(opts&&opts.centerLat)||44.801473617553710;
  defaultZoom=(opts&&opts.startZoom)||10;
  window.onload=loadingGoogleMapsAsyncronously;
};

var loadingGoogleMapsAsyncronously=function(){
  var host='https://maps.googleapis.com/maps/api/js';
  var script = document.createElement('script');
  script.type = 'text/javascript';
  var baseUrl=host+'?v=3.ex&sensor=false&callback=onGoogleMapLoaded&libraries=geometry';
  if (apikey){ script.src = baseUrl+'&key='+apikey; }
  else{ script.src = baseUrl; }
  document.body.appendChild(script);
  window.onGoogleMapLoaded=onGoogleMapLoaded;
};

var onGoogleMapLoaded=function(){
  initMap();
  initRouter();
};

var initMap=function(){
  var mapOptions = {
    zoom: defaultZoom,
    center: new google.maps.LatLng(defaultCenterLat,defaultCenterLng),
    mapTypeId: google.maps.MapTypeId.TERRAIN
  };
  map=new google.maps.Map(mapElement, mapOptions);
  map.loadData=function(id){
    var url=id ? '/geo/map.json?id='+id : '/geo/map.json';
    map.data.loadGeoJson(url);
  };
  map.data.setStyle({
    strokeColor:'#FF0000',
    strokeWeight:1,
    strokeOpacity:0.5,
  });
  map.loadData();
};

// router

var initRouter=function(){
  // create application
  app=router.initApplication({map:map,toolbar:toolbarElement,sidebar:sidebarElement});

  // adding pages to the application
  app.addPage('root', pages.home());
  app.addPage('new_path', pages.new_path());
  app.addPage('edit_path', pages.edit_path());

  // start with root page
  app.openPage('root');
};
},{"./api":1,"./pages":7,"./router":9,"./ui":12}],3:[function(require,module,exports){
var app=require('./app');

app.start();
},{"./app":2}],4:[function(require,module,exports){
var ui=require('../ui')
  , api=require('../api')
  , geo=require('./geo')
  ;

var map
  , feature
  , path
  , layout
  , uiInitialized=false
  , toolbar=ui.button.toolbar([])
  , titleElement=ui.html.pageTitle('გზის შეცვლა')
  , desriptionElement=ui.html.p('გზის შესაცვლელად გამოიყენეთ თქვენი მაუსი. რედაქტირების დასრულების შემდეგ დააჭირეთ შენახვის ღილაკს.',{style:'margin-top:8px;'})
  , notLocked
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;
      notLocked=true;

      if (!uiInitialized){ initUI(self); }

      map=self.map;
      feature=self.params.feature;
      initMap();

      return layout;
    },
    onExit: function() {
      geo.resetMap(map);
    },
  };
};

var initUI=function(self){
  var btnBack=ui.button.actionButton('უკან', function(){
    path.setMap(null);
    map.data.add(feature);
    self.openPage('root');
  }, {icon:'arrow-left'});

  var btnSave=ui.button.actionButton('გზის შენახვა', function(){
    notLocked=!api.editPath(feature.getId(),path.getPath(), function(data){
      path.setMap(null);
      map.loadData(data.id);
      self.openPage('root');
    });
  }, {icon:'save', type:'success'});

  toolbar.addButton(btnBack);
  toolbar.addButton(btnSave);

  layout=ui.layout.vertical({
    children: [
      titleElement,
      toolbar,
      desriptionElement,
    ]
  });

  uiInitialized=true;
};

var initMap=function(){
  if(!path) {
    path=new google.maps.Polyline({
      geodesic:true,
      strokeColor:'#0000FF',
      strokeOpacity:1.0,
      strokeWeight:1,
      editable:true,
    });
    marker = new google.maps.Marker({
      icon: {
        path: google.maps.SymbolPath.CIRCLE,
        fillOpacity: 0,
        strokeOpacity: 1,
        strokeColor: '#FF0000',
        strokeWeight: 1,
        scale: 10, //pixels
      }
    });
  }
  path.getPath().clear();
  path.setMap(map);

  geo.copyFeatureToPath(feature,path);
  map.data.remove(feature);

  var extendPath=function(evt){
    if(notLocked){
      path.getPath().push(evt.latLng);
    }
  };

  google.maps.event.addListener(map, 'click', extendPath);
  google.maps.event.addListener(marker, 'click', extendPath);

  google.maps.event.addListener(path, 'dblclick', function(evt){
    if(notLocked){
      if(typeof evt.vertex==='number'){
        path.getPath().removeAt(evt.vertex,1);
      }
    }
  });

  map.data.addListener('mouseover', function(evt) {
    if(notLocked){
      map.data.overrideStyle(evt.feature,{strokeWeight:10,strokeColor:'#00FF00'});
      marker.setMap(map);
    }
  });

  map.data.addListener('mouseout', function(evt) {
    if(notLocked){
      map.data.revertStyle();
      marker.setMap(null);
    }
  });

  map.data.addListener('mousemove', function(evt){
    if(notLocked){
      marker.setPosition(geo.closestFeaturePoint(evt.feature,evt.latLng));
    }
  });
};

},{"../api":1,"../ui":12,"./geo":5}],5:[function(require,module,exports){
exports.resetMap=function(map){
  google.maps.event.clearInstanceListeners(map);
  google.maps.event.clearInstanceListeners(map.data);
  map.data.revertStyle();
};

exports.copyFeatureToPath=function(feature,path){
  var g=feature.getGeometry();
  var ary=g.getArray();
  path.getPath().clear();
  for(var i=0,l=ary.length;i<l;i++){
    var p=ary[i];
    var point=new google.maps.LatLng(p.lat(),p.lng());
    path.getPath().push(point);
  }
};

exports.closestFeaturePoint=function(feature,point){
  var minDistance
    , minPoint
    ;
  var g=feature.getGeometry();
  var ary=g.getArray();
  for(var i=0,l=ary.length;i<l;i++){
    var p=ary[i];
    var x=new google.maps.LatLng(p.lat(),p.lng());
    var distance=google.maps.geometry.spherical.computeDistanceBetween(p,point);
    if(!minDistance || distance<minDistance){
      minDistance=distance;
      minPoint=p;
    }
  }
  return minPoint;
};

exports.calcFeatureDistance=function(map,feature){
  if(feature instanceof Array){
    var fullDistance=0;
    for(var p=0,q=feature.length;p<q;p++){
      fullDistance+=exports.calcFeatureDistance(map,feature[p]);
    }
    return fullDistance;
  }
  var g=feature.getGeometry()
    , dist=0
    , ary=g.getArray()
    , p0=ary[0]
    ;
  for(var i=0,l=ary.length;i<l;i++){
    var p=ary[i];
    dist+=google.maps.geometry.spherical.computeDistanceBetween(p0,p);
    p0=p;
  }
  return dist/1000;
};
},{}],6:[function(require,module,exports){
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

},{"../api":1,"../ui":12,"./geo":5}],7:[function(require,module,exports){
var home=require('./home')
  , new_path=require('./new_path')
  , edit_path=require('./edit_path')
  ;

exports.home=home;
exports.new_path=new_path;
exports.edit_path=edit_path;
},{"./edit_path":4,"./home":6,"./new_path":8}],8:[function(require,module,exports){
var ui=require('../ui')
  , api=require('../api')
  , geo=require('./geo')
  ;

var map
  , marker
  , layout
  , uiInitialized=false
  , titleElement=ui.html.pageTitle('ახალი გზის დამატება')
  , toolbar=ui.button.toolbar([])
  , desriptionElement=ui.html.p('ახალი გზის გასავლებად გამოიყენეთ თქვენი მაუსი. რედაქტირების დასრულების შემდეგ დააჭირეთ შენახვის ღილაკს.',{style:'margin-top:8px;'})
  , canEdit=true
  , path
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;

      if(!uiInitialized){ initUI(self); }

      canEdit=true;
      map=self.map;
      initMap();

      return layout;
    },
    onExit: function() {
      geo.resetMap(map);
    },
  };
};

var initUI=function(self){
  var btnBack=ui.button.actionButton('უკან', function(){
    path.setMap(null);
    self.openPage('root');
  }, {icon:'arrow-left'});

  var btnSave=ui.button.actionButton('გზის შენახვა', function(){
    canEdit=!api.newPath(path.getPath(), function(data){
      path.setMap(null);
      map.loadData(data.id);
      self.openPage('root');
    });
  }, {icon:'save', type:'success'});

  toolbar.addButton(btnBack);
  toolbar.addButton(btnSave);

  layout=ui.layout.vertical({
    children: [
      titleElement,
      toolbar,
      desriptionElement,
    ]
  });

  uiInitialized=true;
};

var initMap=function(){
  if(!path) {
    path=new google.maps.Polyline({
      geodesic:true,
      strokeColor:'#0000FF',
      strokeOpacity:1.0,
      strokeWeight:1,
      editable:true,
    });
    marker = new google.maps.Marker({
      icon: {
        path: google.maps.SymbolPath.CIRCLE,
        fillOpacity: 0,
        strokeOpacity: 1,
        strokeColor: '#FF0000',
        strokeWeight: 1,
        scale: 10, //pixels
      }
    });
  }
  path.getPath().clear();
  path.setMap(map);

  var extendPath=function(evt){
    if(canEdit){
      path.getPath().push(evt.latLng);
    }
  };

  google.maps.event.addListener(map, 'click', extendPath);
  google.maps.event.addListener(marker, 'click', extendPath);

  google.maps.event.addListener(path, 'dblclick', function(evt){
    if(canEdit){
      if(typeof evt.vertex==='number'){
        path.getPath().removeAt(evt.vertex,1);
      }
    }
  });

  map.data.addListener('mouseover', function(evt) {
    if(canEdit){
      map.data.overrideStyle(evt.feature,{strokeWeight:10,strokeColor:'#00FF00'});
      marker.setMap(map);
    }
  });

  map.data.addListener('mouseout', function(evt) {
    if(canEdit){
      map.data.revertStyle();
      marker.setMap(null);
    }
  });

  map.data.addListener('mousemove', function(evt){
    if(canEdit){
      marker.setPosition(geo.closestFeaturePoint(evt.feature,evt.latLng));
    }
  });
};
},{"../api":1,"../ui":12,"./geo":5}],9:[function(require,module,exports){
var map
  , sidebar
  , toolbar
  , currentPage
  , pages={}
  ;

exports.initApplication=function(opts){
  map=opts.map;
  toolbar=opts.toolbar;
  sidebar=opts.sidebar;
  return {
    addPage: addPage,
    openPage: openPage,
  };
};

var addPage=function(name,page){
  page.openPage=openPage;
  pages[name]=page;
};

var openPage=function(name,params){
  // exiting currently open page
  if(currentPage){
    if(currentPage.onPause){
      var resp=currentPage.onPause();
      if(resp===false){ return; }
    }
    if(currentPage.onExit){
      currentPage.onExit();
    }
  }

  // clear sidebar
  sidebar.innerText='';

  // opening new page
  currentPage=pages[name];

  currentPage.map=map;

  if(currentPage){
    currentPage.params=params;
    if(currentPage.onEnter){
      var pageLayout=currentPage.onEnter();
      sidebar.appendChild(pageLayout);
    }
    if(currentPage.onStart){
      currentPage.onStart();
    }
  }
};

},{}],10:[function(require,module,exports){
var html=require('./html')
  , utils=require('./utils')
  ;

var btnClassNames=function(opts){
  var classNames;
  opts=opts || {};
  if(opts.type===false){
    classNames=[]; // plain link!
  } else {
    opts.type=opts.type||'default';
    classNames=['btn','btn-sm','btn-'+opts.type]
  }
  return classNames;
};

var ensureClassName=function(el,className,classNamePresent){
  var currentClassNames=el.className.split(' ').filter(function(x){return x!=className;});
  if(classNamePresent){ currentClassNames.push(className); }
  el.className=currentClassNames.join(' ');
};

exports.actionButton=function(text,action_f,opts){
  var children = utils.isArray(text) ? text : [text];

  if(opts&&opts.icon){
    var icon=html.el('i',{class:'fa fa-'+opts.icon});
    children=[icon,' '].concat(children);
  }

  var el= html.el('a',{href:'#',class:btnClassNames(opts)},children);
  var enabled=opts&&opts.enabled;
  if(enabled!==false&&enabled!==true){ enabled=true; }
  el.onclick=function(){
    if(action_f && enabled){ action_f(); }
    return false;
  }
  el.setEnabled=function(val){ enabled=val;ensureClassName(el,'disabled',!enabled); };
  el.setWaiting=function(val){ el.setEnabled(!val);ensureClassName(el,'waiting',!enabled); };

  return el;
};

exports.actionLink=function(text,action_f,opts){
  opts=opts || {};
  opts.type=false; // disable button
  return this.actionButton(text,action_f,opts);
};

exports.buttonGroup=function(buttons){
  return html.el('div',{class:'btn-group'},buttons);
};

exports.toolbar=function(buttons){
  var toolbar=html.el('div',{class:'btn-toolbar'},buttons)
  toolbar.addButton=function(button){
    toolbar.appendChild(button);
  };
  toolbar.clearButtons=function(){
    toolbar.innerHTML='';
  };
  return toolbar;
};

exports.dropdown=function(text,buttons,opts){
  var classes=btnClassNames(opts).concat(['dropdown-toggle']);
  if(utils.isArray(text)){text=text.push(' ');} else{text=[text,' '];}
  text.push(html.el('span',{class:'caret'}));
  var btn=html.el('button',{class:classes,'data-toggle':'dropdown'},text);
  var dd=html.el('ul',{class:'dropdown-menu'},buttons.map(function(x){ return html.el('li',[x]); }));
  return html.el('div',{class:'btn-group'},[btn,dd]);
};
},{"./html":11,"./utils":14}],11:[function(require,module,exports){
var utils=require('./utils');

var dashedToCamelized=function(name){
  var firstToUpper=function(x){return [x.substring(0,1).toUpperCase(),x.substring(1)].join('');};
  var parts=name.split('-');
  return [parts[0]].concat(parts.slice(1).map(firstToUpper)).join('');
};

var applyAttribute=function(element,attrName,attrValue){
  if('class'===attrName){

    // class => className
    if(utils.isArray(attrValue)){ element.className=attrValue.join(' '); }
    else{ element.className=attrValue; }
  }
  else if('style'===attrName && attrValue){

    // styles

    var styles=attrValue.split(';');

    for(var i=0,l=styles.length;i<l;i++) {
      var styleInfo=styles[i];
      if(styleInfo && styleInfo.length>0){
        var colonIndex=styleInfo.indexOf(':');
        var styleName=dashedToCamelized(styleInfo.substring(0,colonIndex)).trim();
        var styleValue=styleInfo.substring(colonIndex+1).trim();
        element.style[styleName]=styleValue;
      }
    }
  }
  else{ element.setAttribute(attrName,attrValue); }
};

var createElement=function(tag,attrs,children){
  var element = document.createElement(tag);
  if(attrs){ for(attrName in attrs){ applyAttribute(element,attrName,attrs[attrName]); } }
  if(children){
    for(var i=0,l=children.length;i<l;i++){
      var child=children[i];
      if(typeof child==='string'){ element.appendChild(document.createTextNode(child)); }
      else if(utils.isElement(child)){ element.appendChild(child); }
    }
  }
  return element;
};

/**
 * ```
 * el([parent],tag,[attributes],[children])
 * ```
 *
 * `parent`:Element parent for this element
 * `tag`:String tag name
 * `attributes`:Object tag attributes
 * `children`:{Element|Array|String}
 */
exports.el=function(){
  var parent,tag,attrs,children;
  var curr_index=0;

  // first argument may be a parent
  if(utils.isElement(arguments[curr_index])){ parent=arguments[curr_index]; curr_index+=1; }

  // argument[curr_index] is mandatory 
  tag=arguments[curr_index]; curr_index+=1;
  if(typeof tag !== 'string'){ throw "Tag not defined"; }

  // getting attributes
  if(!utils.isArray(arguments[curr_index]) && typeof arguments[curr_index]==='object'){ attrs=arguments[curr_index]; curr_index+=1; }

  // getting children
  if(typeof arguments[curr_index]==='string' || utils.isElement(arguments[curr_index])){
    children=[ arguments[curr_index] ]; curr_index+=1;
  } else if(utils.isArray(arguments[curr_index])){
    children=arguments[curr_index]; curr_index+=1;
  }

  // create element
  var element=createElement(tag,attrs,children);

  // if parent is given, then append this element to parent
  if (element && parent){ parent.appendChild(element); }

  return element;
};

exports.pageTitle=function(title,tag){
  return exports.el(tag||'h3',{class:'page-header'},title);
};

exports.p=function(text,opts){
  var p=exports.el('p',opts||{},text);
  p.setText=function(text){ p.innerText=text; };
  p.setHtml=function(html){ p.innerHTML=html; }
  return p; 
};

},{"./utils":14}],12:[function(require,module,exports){
var button=require('./button')
  , layout=require('./layout')
  , html=require('./html')
  ;

exports.html=html;
exports.button=button;
exports.layout=layout;

},{"./button":10,"./html":11,"./layout":13}],13:[function(require,module,exports){
var html=require('./html')
 ;

/**
 * Vertical layout.
 */
exports.vertical=function(opts){
  var layout
    , childElements=[]
    ;

  if(opts.parent){ layout=html.el(opts.parent,'div',{class:'vertical-layout'}); }
  else { layout=html.el('div',{class:'vertical-layout'}); }

  var addToLayout=function(child){
    var childElement=html.el(layout,'div',[child]);
    childElements.push(childElement);
  };

  if(opts.children){
    var children=opts.children;
    for(var i=0, l=children.length; i<l; i++){
      addToLayout(children[i]);
    }
  }

  layout.add=addToLayout;

  return layout;
};

/**
 * Card layout.
 */
exports.card=function(opts){
  var layout
    , childElements=[]
    , selectedIndex
    ;

  if(opts.parent){ layout=html.el(opts.parent,'div',{class:'card-layout'}); }
  else{ layout=html.el('div',{class:'card-layout'}); }

  var addToLayout=function(child){
    childElements.push(child);
    if(!selectedIndex){ select(0); }
  };

  var select=function(idx){
    if(idx!==selectedIndex) {
      var oldElement=childElements[selectedIndex];
      if(oldElement){ layout.removeChild(oldElement); }
      var newElement=childElements[idx];
      layout.appendChild(newElement);
      selectedIndex=idx;
    }
  };

  if(opts.children){
    var children=opts.children;
    for(var i=0, l=children.length; i<l; i++){
      addToLayout(children[i]);
    }
  }

  layout.add=addToLayout;
  layout.showAt=select;

  return layout;
};
},{"./html":11}],14:[function(require,module,exports){
exports.isArray=function(x){ return x && (x instanceof Array); };
exports.isElement=function(x){ return x && ((x instanceof Element) || (x instanceof Document)); }
exports.fieldValue=function(object,name){ return object&&object[name]; };
},{}]},{},[3])