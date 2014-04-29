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
    $.post(BASE_PATH+'/new_path',{points:points},function(data) {
      callback(data);
    });
    return true;
  }
  return false;
};

exports.editPath=function(id,path,callback){
  if(path.getLength()>1){
    var points=pointsFromPath(path);
    $.post(BASE_PATH+'/edit_path',{id:id,points:points},function(data) {
      callback(data);
    });
    return true;
  }
  return false;
};
},{}],2:[function(require,module,exports){
var draw=require('./draw')
  , ui=require('./ui')
  , api=require('./api')
  ;

var mapElement;
var sidebarElement;
var toolbarElement;
var apikey;
var defaultCenterLat;
var defaultCenterLng;
var defaultZoom;
var map;

/**
 * This function is used to start the application.
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
  
};

var initMap=function(){
  var mapOptions = {
    zoom: defaultZoom,
    center: new google.maps.LatLng(defaultCenterLat,defaultCenterLng),
    mapTypeId: google.maps.MapTypeId.TERRAIN
  };
  map=new google.maps.Map(mapElement, mapOptions);

  loadData(map);

  var pauseEditing=function() {
    btnSavePath.setWaiting(true);
    drawHandle.setPaused(true);
  };
  var resumeEditing=function(data){
    btnSavePath.setWaiting(false);
    drawHandle.setPaused(false);
    drawHandle.restartEdit();
  };

  var btnSavePath=ui.button.actionButton('გზის შენახვა', function(){
    var path=drawHandle.getPath();
    var id=path.id;
    pauseEditing();
    if(id){
      var resp=api.editPath(id,path,function(data){
        loadData(map,data.id);
        console.log(data);
        resumeEditing();
      });
      if(!resp){ resumeEditing(); }
    } else {
      var resp=api.newPath(path, function(data){
        loadData(map,data.id);
        resumeEditing();
      });
      if(!resp){ resumeEditing(); }
    }
  });
  toolbarElement.appendChild(btnSavePath);

  // draw path
  var drawHandle=draw.drawPath(map);
};

var loadData=function(map,id){
  var url=id? '/geo/map.json?id='+id:'/geo/map.json'
  console.log(url);
  map.data.loadGeoJson(url);
  map.data.setStyle({
    strokeColor:'red',
    strokeWeight:1,
    strokeOpacity:0.5,
  });
};
},{"./api":1,"./draw":3,"./ui":7}],3:[function(require,module,exports){
var resetMap=function(map){
  google.maps.event.clearInstanceListeners(map);
};

var copyFeatureToPath=function(feature,path){
  var g=feature.getGeometry();
  var ids=feature.getProperty('point_ids').split(',');
  var ary=g.getArray();
  path.getPath().clear();    
  for(var i=0,l=ary.length;i<l;i++){
    var p=ary[i];
    var point=new google.maps.LatLng(p.lat(),p.lng());
    point.id=ids[i];
    path.getPath().push(point);
  }
};

var closestPointTo=function(feature,point){
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

exports.drawPath=function(map){
  var path=new google.maps.Polyline({
    map:map,
    geodesic:true,
    strokeColor:'#FF0000',
    strokeOpacity:1.0,
    strokeWeight:1,
    editable:true,
  });
  var paused=false
    , featureId=undefined
    ;
  var featureCircle=new google.maps.Circle({
    strokeColor: '#FF0000',
    strokeOpacity: 0.8,
    strokeWeight: 1,
    fillColor: '#FF0000',
    fillOpacity: 0.35,
    radius: 50,
  });

  google.maps.event.addListener(map, 'click', function(evt){
    if(!paused){ path.getPath().push(evt.latLng); }
  });

  google.maps.event.addListener(path, 'dblclick', function(evt){
    if(!paused){
      if(typeof evt.vertex==='number'){
        path.getPath().removeAt(evt.vertex,1);
      }
    }
  });

  map.data.addListener('click', function(evt) {
    if(!paused){
      var closestPoint=closestPointTo(evt.feature,evt.latLng);
      closestPoint.featureId=evt.feature.getId();
      path.getPath().push(closestPoint);
    }
  });

  map.data.addListener('mouseover', function(evt) {
    map.data.overrideStyle(evt.feature,{strokeWeight:10,strokeColor:'green'});
    featureCircle.setMap(map);
  });

  map.data.addListener('mouseout', function(evt) {
    map.data.revertStyle();
    featureCircle.setMap(null);
  });

  map.data.addListener('mousemove', function(evt){
    featureCircle.setCenter(closestPointTo(evt.feature,evt.latLng));
  });

  map.data.addListener('dblclick', function(evt) {
    var f=evt.feature;
    featureId=f.getId();
    copyFeatureToPath(f,path);
    map.data.remove(f);
    evt.stop();
  });

  return {
    getPath: function(){ var p=path.getPath(); p.id=featureId; return p; },
    restartEdit: function(){ path.getPath().clear(); featureId=undefined; },
    setPaused: function(val){ paused=val; },
    endEdit: function() {
      resetMap(map);
      path.setMap(null);
    },
  };
};
},{}],4:[function(require,module,exports){
var app=require('./app');

app.start();
},{"./app":2}],5:[function(require,module,exports){
var html=require('./html')
  , utils=require('./utils');

var btnClassNames=function(opts){
  var classNames;
  opts=opts || {};
  if(opts.type===false){ classNames=[]; }  
  else {
    opts.type=opts.type||'default';
    // var size=opts.size=='small'?'btn-xs':'btn-sm';
    // classNames=['btn','btn-'+opts.type,size];
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
  var el= html.el('a',{href:'#',class:btnClassNames(opts)},text);
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
  return html.el('div',{class:'btn-toolbar'},buttons);
};

exports.dropdown=function(text,buttons,opts){
  var classes=btnClassNames(opts).concat(['dropdown-toggle']);
  if(utils.isArray(text)){text=text.push(' ');} else{text=[text,' '];}
  text.push(html.el('span',{class:'caret'}));
  var btn=html.el('button',{class:classes,'data-toggle':'dropdown'},text);
  var dd=html.el('ul',{class:'dropdown-menu'},buttons.map(function(x){ return html.el('li',[x]); }));
  return html.el('div',{class:'btn-group'},[btn,dd]);
};
},{"./html":6,"./utils":8}],6:[function(require,module,exports){
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
        var styleName=dashedToCamelized(styleInfo.substring(0,colonIndex));
        var styleValue=styleInfo.substring(colonIndex+1);
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
  return exports.el('p',opts,text);
};
},{"./utils":8}],7:[function(require,module,exports){
var button=require('./button')
  ;

exports.button=button;
},{"./button":5}],8:[function(require,module,exports){
exports.isArray=function(x){ return x && (x instanceof Array); };
exports.isElement=function(x){ return x && ((x instanceof Element) || (x instanceof Document)); }
exports.fieldValue=function(object,name){ return object&&object[name]; };
},{}]},{},[4])